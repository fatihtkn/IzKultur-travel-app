// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

Random random = Random();



List<TravelPlaces> travelPlacesTest = [];
class TravelPlaces {
  final String district;
  final List<String> images;
  final String name, description;
  final GeoPoint location;
  final double rate;
  bool isBookmarked;

  TravelPlaces({
    required this.district,
    required this.name,
    required this.description,
    required this.images,
    required this.rate,
    required this.location,
    this.isBookmarked = false,
  });

  static Future<List<TravelPlaces>> getTravelPlaces(String selectedCity) async {
    String sluggedCity = slugify(selectedCity);
    List<TravelPlaces> travelPlaces = [];
    var firestore = FirebaseFirestore.instance;
    var collectionRef = firestore
        .collection('districts')
        .doc(sluggedCity)
        .collection('places');

    var snapshot = await collectionRef.get();

    for (var doc in snapshot.docs) {
      var data = doc.data();
      var travelPlace = TravelPlaces(
        district: selectedCity,
        name: data['name'],
        description: data['description'],
        images: List<String>.from(data['images']),
        rate: (data['point'] as num).toDouble(),
        location: data['location'],
      );
      travelPlaces.add(travelPlace);
    }

    return travelPlaces;
  }


  static Future<void> updateTravelPlacesBySelectedDistrict(String selectedDistrict) async {
    String sluggedDistrict = slugify(selectedDistrict);
    var firestore = FirebaseFirestore.instance;
    var collectionRef = firestore
        .collection('districts')
        .doc(sluggedDistrict)
        .collection('places');

    var snapshot = await collectionRef.get();
    
    for (var doc in snapshot.docs) {
      var data = doc.data();
      var travelPlace = TravelPlaces(
        district: selectedDistrict,
        name: data['name'],
        description: data['description'],
        images: List<String>.from(data['images']),
        rate: (data['point'] as num).toDouble(),
        location: data['location'],
      );
      print(travelPlace.name);
      travelPlacesTest.add(travelPlace);
    }

   
  }
  
  
  
  
  static String  slugify(String selectedDistrict) {
    return selectedDistrict
        .toLowerCase()
        .trim()
        .replaceAll('ç', 'c')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ş', 's')
        .replaceAll('ü', 'u');
  }
}

