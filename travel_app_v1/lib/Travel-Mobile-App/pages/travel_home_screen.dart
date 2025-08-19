import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/pages/bookmarked_places_page.dart';
import 'package:travel_app/Travel-Mobile-App/pages/place_detail.dart';
import 'package:travel_app/Travel-Mobile-App/pages/all_popular_places.dart';
import 'package:travel_app/Travel-Mobile-App/pages/profile_page.dart';
import 'package:travel_app/Travel-Mobile-App/pages/login_screen.dart';
import 'package:travel_app/Travel-Mobile-App/widgets/popular_place.dart';
import 'package:travel_app/Travel-Mobile-App/widgets/recomendate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';
import '../models/travel_model.dart';

class TravelHomeScreen extends StatefulWidget {
  const TravelHomeScreen({super.key});

  @override
  State<TravelHomeScreen> createState() => _TravelHomeScreenState();
}

class _TravelHomeScreenState extends State<TravelHomeScreen> {
  int selectedPage = 0;
  String selectedDistrict = 'Konak';
  bool isNotificationPanelOpen = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  List<String> districts = [
    'Aliağa','Balçova','Bayraklı','Bergama','Bornova','Buca','Çeşme','Foça','Gaziemir','Güzelbahçe',
    'Karaburun','Karşıyaka','Konak','Menderes','Narlıdere','Seferihisar','Selçuk','Torbalı','Urla'
  ];
 

  List<String> notifications = [
    'Yeni öneriler eklendi!',
    'Favori mekanında indirim var!',
    'Yakınlarda popüler bir etkinlik var.',
    'Yeni bir mekan keşfettin!',
    'Sana özel bir kampanya var!',
    'Yeni bir mekan önerisi geldi!',
    'Favori mekanında yeni bir etkinlik var.',
  ];

  List<IconData> icons = [
    Iconsax.home1,
    Icons.bookmark_outline,
    Icons.person_outline,
  ];

  
  List<TravelPlaces> recomendedPlaces =[];
      

  
  late List<Widget> pages;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  Future<void> _fetchUserData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      // Önceki dinleyiciyi iptal et
      await _userSubscription?.cancel();

      // Yeni bir dinleyici oluştur
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
        (docSnapshot) {
          if (!mounted) return;

          if (docSnapshot.exists) {
            final data = docSnapshot.data() as Map<String, dynamic>;
            setState(() {
              userData = data;
              pages = [
                buildMainPage(),
                const BookmarkedPlacesPage(),
                ProfilePage(
                  initialName: data['name'] ?? 'Kullanıcı',
                  initialEmail: data['email'] ?? '',
                  initialPhone: data['phone'] ?? '',
                  initialBio: data['bio'] ?? 'Hoş geldiniz!',
                  initialLocation: data['location'] ?? 'İzmir',
                  initialPhoto: data['profilePhoto'] ?? defaultProfilePhoto,
                ),
              ];
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage = 'Kullanıcı bilgileri bulunamadı.';
              isLoading = false;
            });
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            errorMessage = 'Veri alınırken bir hata oluştu: $error';
            isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Bir hata oluştu: $e';
        isLoading = false;
      });
    }
  }






 Future<void> loadPlacesData() async {
  setState(() {
      isLoading = true;
    });

    await TravelPlaces.updateTravelPlacesBySelectedDistrict(selectedDistrict); // örnek şehir
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchPlaces(String district) async {

  setState(() {
    isLoading = true;
  });

  travelPlacesTest.clear(); // listeyi temizle
  await TravelPlaces.updateTravelPlacesBySelectedDistrict(selectedDistrict);

  setState(() {
    isLoading = false;
  });
}

Future<void> getRandomRecommendPlace() async {
  try {
    setState(() {
      isLoading = true;
    });

    List<String> availableDistricts = List.from(districts);
    availableDistricts.remove(selectedDistrict);

    final random = Random();
    String randomDistrict = availableDistricts[random.nextInt(availableDistricts.length)];

    recomendedPlaces = await TravelPlaces.getTravelPlaces(randomDistrict);
  } catch (e) {
    // Hata yönetimi: loglama, kullanıcıya mesaj vs.
    // ignore: avoid_print
    print("Hata oluştu: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



  @override
  void initState() {
    super.initState();
    pages = [
      buildMainPage(),
      const BookmarkedPlacesPage(),
      ProfilePage(
        initialName: "Kullanıcı",
        initialEmail: "kullanici@email.com",
        initialPhone: "+90 555 555 5555",
        initialBio: "Hoş geldiniz!",
        initialLocation: "İzmir",
        initialPhoto: defaultProfilePhoto
      ),
    ];
    _fetchUserData();
    loadPlacesData();
    getRandomRecommendPlace();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
     
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                    isLoading = true;
                  });
                  _fetchUserData();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: selectedPage == 0 ? headerParts() : null,
      body: Stack(
        children: [
          selectedPage == 0 ? buildMainPage() : pages[selectedPage],
          if (isNotificationPanelOpen)
            Positioned(
              top: 2,
              left: 20,
              right: 20,
              child: Material(
                borderRadius: BorderRadius.circular(15),
                elevation: 5,
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  height: 300,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bildirimler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                notifications.clear();
                                isNotificationPanelOpen = false;
                              });
                            },
                            child: const Text(
                              'Temizle',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: notifications.isEmpty
                            ? const Center(
                                child: Text("Hiç bildirimin yok!"),
                              )
                            : ListView.builder(
                                itemCount: notifications.length,
                                itemBuilder: (context, index) => Dismissible(
                                  key: Key(notifications[index]),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) {
                                    setState(() {
                                      notifications.removeAt(index);
                                      if (notifications.isEmpty) isNotificationPanelOpen = false;
                                    });
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    color: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(Icons.close, color: Colors.white),
                                  ),
                                  child: ListTile(
                                    title: Text(notifications[index]),
                                  ),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: kButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            icons.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedPage = index;
                });
              },
              child: Icon(
                icons[index],
                size: 30,
                color: selectedPage == index
                    ? Colors.white
                    // ignore: deprecated_member_use
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMainPage() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                "$selectedDistrict İçin Popüler Yerler",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                child: const Text(
                  "Tümünü Görüntüle",
                  style: TextStyle(
                    fontSize: 13,
                    color: blueTextColor,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SeeAllPopularPlacesPage(myDestination:travelPlacesTest),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            children: List.generate(
              travelPlacesTest.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailScreen(
                          destination: travelPlacesTest[index],
                        ),
                      ),
                    );
                  },
                  child: PopularPlace(
                    destination: travelPlacesTest[index],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Sizin İçin Önerilen Diğer Yerler",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
            child: Column(
              children: List.generate(
                recomendedPlaces.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(
                            destination: recomendedPlaces[index],
                          ),
                        ),
                      );
                    },
                    child: Recomendate(
                      destination: recomendedPlaces[index],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar headerParts() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leadingWidth: 200,
      leading: Row(
        children: [
          const SizedBox(width: 15),
          const Icon(
            Iconsax.location,
            color: Colors.black,
          ),
          const SizedBox(width: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDistrict,
              items: districts.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDistrict = newValue;
                    fetchPlaces(selectedDistrict);
                    getRandomRecommendPlace();
                  });
                }
              },
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black26),
              borderRadius: BorderRadius.circular(15),
              menuMaxHeight: 250,
            ),
          )
        ],
      ),
      actions: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isNotificationPanelOpen = !isNotificationPanelOpen;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                padding: const EdgeInsets.all(7),
                child: const Icon(
                  Iconsax.notification,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
            if (notifications.isNotEmpty)
              const Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  
  String slugify(String selectedDistrict) {
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
