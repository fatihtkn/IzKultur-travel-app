// ignore_for_file: unused_import, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/pages/login_screen.dart';
import 'package:travel_app/Travel-Mobile-App/pages/travel_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/Travel-Mobile-App/pages/profile_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  bool isLoading = false;

  Future<void> _signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String bio = bioController.text.trim();
    String location = locationController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        bio.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'phone': phone,
        'bio': bio,
        'location': location,
        'profilePhoto': defaultProfilePhoto,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        /*Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              initialName: name,
              initialEmail: email,
              initialPhone: phone,
              initialBio: bio,
              initialLocation: location,
              initialPhoto: defaultProfilePhoto,
            ),
          ),
        );*/

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TravelHomeScreen()
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Kayıt olurken bir hata oluştu.";

      if (e.code == 'weak-password') {
        errorMessage = "Şifre çok zayıf.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Bu e-posta adresi zaten kullanımda.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Geçersiz e-posta adresi.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bir hata oluştu: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 140),
            child: SizedBox.expand(
              child: Image.asset(
                "lib/assets/images/onboarding/4.jpg",
                filterQuality: FilterQuality.none,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: constraints.maxHeight),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    "Kayıt Ol",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Ad ve Soyad",
                                      filled: true,
                                      fillColor: Colors.white70,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    controller: nameController,
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "E-posta",
                                      filled: true,
                                      fillColor: Colors.white70,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      fillColor: Colors.white70,
                                      filled: true,
                                      prefixText: '+90 ',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Bio",
                                      filled: true,
                                      fillColor: Colors.white70,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    controller: bioController,
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Konum",
                                      filled: true,
                                      fillColor: Colors.white70,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    controller: locationController,
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "Şifre",
                                      filled: true,
                                      fillColor: Colors.white70,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                    controller: passwordController,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _signUp,
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text("Devam Et",
                                            style:
                                                TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        ),
                                        child: const Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Hesabın var mı? ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              TextSpan(
                                                text: "Giriş Yap",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
