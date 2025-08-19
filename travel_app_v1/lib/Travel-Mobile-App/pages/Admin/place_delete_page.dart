import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class PlaceDeletePage extends StatefulWidget {
  const PlaceDeletePage({super.key});

  @override
  State<PlaceDeletePage> createState() => _PlaceDeletePageState();
}

class _PlaceDeletePageState extends State<PlaceDeletePage> {
  final List<String> districts = [
    'Aliağa', 'Balçova', 'Bayraklı', 'Bergama', 'Bornova', 'Buca', 'Çeşme',
    'Foça', 'Gaziemir', 'Güzelbahçe', 'Karaburun', 'Karşıyaka', 'Konak',
    'Menderes', 'Narlıdere', 'Seferihisar', 'Selçuk', 'Torbalı', 'Urla',
  ];

  String? selectedDistrict;
  String? slugifiedDistrict = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownSearch<String>(
            items: districts,
            selectedItem: selectedDistrict,
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "İlçe Seç",
                border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              constraints: BoxConstraints(maxHeight: 300), // Maksimum yükseklik
            ),
            onChanged: (val) {
              setState(() {
                selectedDistrict = val;
                slugifiedDistrict = slugify(selectedDistrict!);
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedDistrict == null
                ? const Center(child: Text("İlçe seçiniz"))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("districts")
                        .doc(slugifiedDistrict)
                        .collection("places")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Hata oluştu.");
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("Kayıtlı yer yok.");
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final place = docs[index];
                          return ListTile(
                            title: Text(place['name']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Yer Sil"),
                                    content: const Text("Bu yeri silmek istediğinizden emin misiniz?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("İptal"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text(
                                          "Sil",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await place.reference.delete();
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
}
