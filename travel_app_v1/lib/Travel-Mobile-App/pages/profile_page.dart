import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/pages/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit_page.dart';  // ProfilEditPage'yi import etmeyi unutmayın

class ProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialBio;
  final String initialLocation;
  final String initialPhoto;
  const ProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialBio,
    required this.initialLocation,
    required this.initialPhoto,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  late String _bio;
  late String _email;
  late String _location;
  File? _avatar;
  String? _initialPhoto;
  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _bio = widget.initialBio;
    _email = widget.initialEmail;
    _location = widget.initialLocation;
    _initialPhoto = widget.initialPhoto;
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Çıkış yapılırken bir hata oluştu: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const avatarRadius = 50.0;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Çıkış Yap"),
                    content: const Text("Çıkış yapmak istediğinizden emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _logout();
                        },
                        child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // KAPAK + PROFİL FOTO
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.asset(loginScreenBackgroundImage).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -avatarRadius,
                  left: 20,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: kBackgroundColor,
                    child: CircleAvatar(
                      radius: avatarRadius - 5,
                      backgroundImage: _avatar != null
                        ? FileImage(_avatar!)
                        : (_initialPhoto != null && _initialPhoto!.isNotEmpty)
                        ? NetworkImage(_initialPhoto!)
                      : NetworkImage(defaultProfilePhoto),
                    ),  
                  ),
                ),
              ],
            ),
            SizedBox(height: avatarRadius + 10),

            // İSİM, BIO ve DÜZENLE BUTONU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim & Bio
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _bio,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Düzenle butonu
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileEditPage(
                              name: _name,
                              bio: _bio,
                              email: _email,
                              location: _location,
                              avatar: _avatar,
                            ),
                          ),
                        );
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _name = result['name'];
                            _bio = result['bio'];
                            _email = result['email'];
                            _location = result['location'];
                            _avatar = result['avatar'];
                          });
                        }
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text("Düzenle"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // İLETİŞİM & LOKASYON
            ListTile(
              leading: Icon(Icons.email),
              title: Text(_email),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(widget.initialPhone),
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text(_location),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text("Gezilen Yerler: 0"),
            ),
            SizedBox(height: 20),

            // FAVORİ YERLER
            
            
            

            // ROZETLER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Kazanılan Rozetler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                children: [
                  badgeCard("Yeni Üye", Icons.person_add, true),
                  badgeCard("İzmir Sevdalısı", Icons.favorite, false),
                  badgeCard("Sahil Gezgin", Icons.beach_access, false),
                  badgeCard("Tarih Meraklısı", Icons.history_edu, false),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Rozet Kartı
  Widget badgeCard(String title, IconData iconData, bool unlocked) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: unlocked ? Colors.blueAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                iconData,
                size: 40,
                color: unlocked ? Colors.blueAccent : Colors.grey,
              ),
              if (!unlocked)
                Icon(
                  Icons.lock,
                  size: 20,
                  color: Colors.grey.shade700,
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
