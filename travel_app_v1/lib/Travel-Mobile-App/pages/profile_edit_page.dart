import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditPage extends StatefulWidget {
  final String name;
  final String bio;
  final String email;
  final String location;
  final File? avatar;

  const ProfileEditPage({
    super.key,
    required this.name,
    required this.bio,
    required this.email,
    required this.location,
    this.avatar,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;

  File? _newAvatar;
  String? _initialPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _bioController = TextEditingController(text: widget.bio);
    _emailController = TextEditingController(text: widget.email);
    _locationController = TextEditingController(text: widget.location);
    _newAvatar = widget.avatar;

    _loadInitialPhotoUrl();
  }

  Future<void> _loadInitialPhotoUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      setState(() {
        _initialPhotoUrl = doc.data()?["profilePhoto"];
      });
    }
  }

  Future<String?> _uploadProfileImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final storage = FirebaseStorage.instance;
    final uid = user.uid;

    try {
      // Eski fotoğraf varsa sil
      if (_initialPhotoUrl != null && _initialPhotoUrl!.isNotEmpty) {
        try {
          final ref = storage.refFromURL(_initialPhotoUrl!);
          await ref.delete();
        } catch (e) {
          print("Eski fotoğraf silinemedi: $e");
        }
      }

      final ref = storage.ref().child("profile_photos/$uid.jpg");
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Fotoğraf yüklenirken hata: $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newAvatar = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection("users").doc(user.uid);
    String? newPhotoUrl;

    if (_newAvatar != null) {
      newPhotoUrl = await _uploadProfileImage(_newAvatar!);
    }

    await docRef.update({
      "name": _nameController.text,
      "bio": _bioController.text,
      "email": _emailController.text,
      "location": _locationController.text,
      if (newPhotoUrl != null) "profilePhoto": newPhotoUrl,
    });

    Navigator.pop(context, {
      'name': _nameController.text,
      'bio': _bioController.text,
      'email': _emailController.text,
      'location': _locationController.text,
      'avatar': _newAvatar,
      
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profil güncellendi")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const avatarRadius = 50.0;

    return Scaffold(
      appBar: AppBar(title: Text("Profili Düzenle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _newAvatar != null
                      ? FileImage(_newAvatar!)
                      : widget.avatar != null
                          ? FileImage(widget.avatar!)
                          : null,
                  child: _newAvatar == null && widget.avatar == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: -10,
                  child: IconButton(
                    onPressed: _pickImage,
                    icon: Icon(Icons.camera_alt, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "İsim", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: "Hakkında", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-posta", border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: "Lokasyon", border: OutlineInputBorder()),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Kaydet"),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
          ],
        ),
      ),
    );
  }
}
