// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/pages/Admin/admin_panel.dart';
import 'package:travel_app/Travel-Mobile-App/pages/sign_up.dart';
import 'package:travel_app/Travel-Mobile-App/pages/travel_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

    try 
    {
      

      /*print("Giriş denemesi başlatılıyor...");
      print("E-posta: $email");
      if(email==adminEmail && password==adminPassword){
        print("Admin giriş denemesi yapılıyor...");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanel()),
          );
        }
        return;
      }*/

      
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("Giriş başarılı! Kullanıcı ID: ${userCredential.user?.uid}");
      



      final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .get();

      final role = userDoc.data()?['role'];

      if (role == 'admin') {
        if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPanel()),
        );
        }
      } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TravelHomeScreen()),
        );
      }
    }



    } 
      on FirebaseAuthException catch (e) {
      print("Firebase Auth Hatası: ${e.code} - ${e.message}");
      String errorMessage = "Giriş yapılırken bir hata oluştu.";
      
      if (e.code == 'user-not-found') {
        errorMessage = "Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Hatalı şifre girdiniz.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Geçersiz e-posta adresi.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "Bu hesap devre dışı bırakılmış.";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.";
      } else if (e.code == 'network-request-failed') {
        errorMessage = "İnternet bağlantınızı kontrol edin.";
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = "E-posta/şifre girişi etkin değil.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print("Genel Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Beklenmeyen bir hata oluştu: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
      body: Stack(
        children: [
          // Arka plan görseli
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: SizedBox.expand(
              child: Image.asset(
                "lib/assets/images/onboarding/3.jpg",
                filterQuality: FilterQuality.none,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Saydam panel
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
                  height: MediaQuery.of(context).size.height * 0.4,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "E-posta",
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Şifre",
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: passwordController,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Devam Et",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Hesabın yok mu? ",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Kayıt Ol",
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
            ),
          ),
        ],
      ),
    );
  }
}
