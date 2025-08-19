// ignore_for_file: avoid_print


import 'package:flutter/material.dart';


import 'package:travel_app/Travel-Mobile-App/pages/onboard_travel.dart';
import 'package:firebase_core/firebase_core.dart';


import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase başarıyla başlatıldı");


    } else {
      print("Firebase zaten başlatılmış");
    }
  } catch (e) {
    print("Firebase başlatma hatası: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Firebase başlatılamadı'),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const TravelOnBoardingScreen();
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}






  

