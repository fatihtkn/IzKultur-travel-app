import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/pages/login_screen.dart';
import 'place_add_page.dart';
import 'place_delete_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    PlaceAddPage(),
    PlaceDeletePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Paneli",
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
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
      body: _pages[_currentIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Yer Ekle"),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: "Yer Sil"),
        ],
      ),
    );
  }
}
