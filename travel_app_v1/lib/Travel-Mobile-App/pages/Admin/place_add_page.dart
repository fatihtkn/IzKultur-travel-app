import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/Travel-Mobile-App/pages/location_picker.dart';



class PlaceAddPage extends StatefulWidget {
  const PlaceAddPage({super.key});

  @override
  State<PlaceAddPage> createState() => _PlaceAddPageState();
}

class _PlaceAddPageState extends State<PlaceAddPage> {
  final List<String> districts = [
    'Aliağa', 'Balçova', 'Bayraklı', 'Bergama', 'Bornova', 'Buca', 'Çeşme',
    'Foça', 'Gaziemir', 'Güzelbahçe', 'Karaburun', 'Karşıyaka', 'Konak',
    'Menderes', 'Narlıdere', 'Seferihisar', 'Selçuk', 'Torbalı', 'Urla',
  ];

  String? selectedDistrict;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  LatLng? selectedLatLng;
  List<File> selectedImages = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 75);

    if (pickedFiles != null) {
      setState(() {
        selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(String districtSlug, String placeSlug) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < selectedImages.length; i++) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('place_images/$districtSlug/$placeSlug/image_$i.jpg');
      await ref.putFile(selectedImages[i]);
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  Future<void> _openMapDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPicker(
          initialPosition: LatLng(38.4237, 27.1428),
          isDetailCard: false, // yeni parametre
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        selectedLatLng = result;
      });
    }
  }

  Future<void> _addPlace() async {
    if (selectedDistrict == null ||
        nameController.text.isEmpty ||
        selectedLatLng == null) return;

    String districtSlug = slugify(selectedDistrict!);
    String placeSlug = nameController.text.toLowerCase().replaceAll(' ', '_');
    List<String> imageUrls = await _uploadImages(districtSlug, placeSlug);

    await FirebaseFirestore.instance
        .collection("districts")
        .doc(districtSlug)
        .collection("places")
        .doc(placeSlug)
        .set({
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
      "location": GeoPoint(selectedLatLng!.latitude, selectedLatLng!.longitude),
      "images": imageUrls,
      "point": Random().nextDouble()+4,
      "isBookmarked": false,
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Yer başarıyla eklendi!")),
    );

    nameController.clear();
    descController.clear();
    setState(() {
      selectedLatLng = null;
      selectedImages = [];
      selectedDistrict = null;
    });
  }

  String slugify(String input) {
    return input.toLowerCase().trim()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Yeni Yer Ekle"),backgroundColor: Colors.white,),
      body: 
      SingleChildScrollView(
        
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "İlçe Seç",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              isExpanded: true,
              value: selectedDistrict,
              items: districts
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedDistrict = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Yer Adı",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Açıklama",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openMapDialog,
              icon: const Icon(Icons.map),
              label: Text(selectedLatLng == null
                  ? "Konum Seç"
                  : "Seçilen Konum: (${selectedLatLng!.latitude.toStringAsFixed(4)}, ${selectedLatLng!.longitude.toStringAsFixed(4)})"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo),
              label: const Text("Fotoğraf Seç"),
            ),
            const SizedBox(height: 12),
            if (selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.file(selectedImages[i]),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addPlace,
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
