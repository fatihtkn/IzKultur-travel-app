// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Asset klasöründen bir dosyayı geçici dosyaya kopyalar, Firebase Storage'a yükler ve URL döner.
Future<String> uploadAssetImage(String assetPath, String storagePath) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
  await tempFile.writeAsBytes(byteData.buffer.asUint8List());

  final ref = FirebaseStorage.instance.ref().child(storagePath);
  await ref.putFile(tempFile);
  return await ref.getDownloadURL();
}

/// Türkçe karakterleri temizleyerek slug oluşturur.
String slugify(String text) {
  return text
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u');
}

/// Tüm verileri ve görselleri yükler, Firestore'daki places belgelerine "images" alanı olarak URL listesi ekler.
Future<void> uploadImagesAndUpdateFirestore() async {
  final rawJson = await rootBundle.loadString('lib/assets/Jsons/places.json');
  final Map<String, dynamic> data = jsonDecode(rawJson);
  final firestore = FirebaseFirestore.instance;

  final List<String> extensions = ['jpg','jpeg','png','webp'];
  const int maxImages = 10;

  for (final district in data.entries) {
    final districtId = district.key;
    final places = district.value;

    if (places is! List) {
      print('❌ $districtId altındaki veri bir liste değil.');
      continue;
    }

    for (final place in places) {
      final placeName = place['name'];
      final placeSlug = slugify(placeName);
      final folderPath = 'lib/assets/districts/$districtId/$placeSlug';

      List<String> imageUrls = [];

      for (int i = 1; i <= maxImages; i++) {
        bool found = false;
        for (final ext in extensions) {
          final assetPath = '$folderPath/$i.$ext';
          
          final storagePath = 'place_images/$districtId/$placeSlug/$i.$ext';
          try {
            final url = await uploadAssetImage(assetPath, storagePath);
            imageUrls.add(url);
            found = true;
            break;
          } catch (e) {
          print('Dosya yüklenirken hata: $assetPath - $e');
          }
        }
        if (!found) break; // hiç uzantı bulunamadıysa daha fazla resim yoktur
      }

      // Eğer hiç görsel bulunamadıysa default resim kullan
      if (imageUrls.isEmpty) {
        final defaultUrl = await uploadAssetImage(
          'lib/assets/districts/default.png',
          'place_images/$districtId/$placeSlug/default.png',
        );
        imageUrls.add(defaultUrl);
        print('⚠️ $placeName için görsel bulunamadı, default eklendi.');
      }

      // Firestore'a yaz
      final placeRef = firestore
          .collection('districts')
          .doc(districtId)
          .collection('places')
          .doc(placeSlug);

      await placeRef.set({'images': imageUrls}, SetOptions(merge: true));
      print('✅ $placeName için ${imageUrls.length} görsel yüklendi.');
    }
  }

  print('🎉 Tüm yerler için işlem tamamlandı.');
}
