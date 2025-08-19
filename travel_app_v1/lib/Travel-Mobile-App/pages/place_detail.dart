import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/models/travel_model.dart';
import 'package:travel_app/Travel-Mobile-App/pages/location_picker.dart';

class PlaceDetailScreen extends StatefulWidget {
  final TravelPlaces destination;
  const PlaceDetailScreen({super.key, required this.destination});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  PageController pageController = PageController();
  int pageView = 0;

  Future<void> _openMapDialog(double latitude, double longitude) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          initialPosition: LatLng(latitude, longitude),
          isDetailCard: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 64,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(""),
        actions: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.destination.isBookmarked =
                      !widget.destination.isBookmarked;
                });
              },
              child: Icon(
                widget.destination.isBookmarked
                    ? Icons.bookmark
                    : Icons.bookmark_outline,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Image Carousel Section
            Container(
              height: screenHeight * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 5),
                    blurRadius: 7,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    PageView(
                      controller: pageController,
                      onPageChanged: (value) {
                        setState(() {
                          pageView = value;
                        });
                      },
                      children: List.generate(
                        widget.destination.images.length,
                        (index) => Image.network(
                          fit: BoxFit.cover,
                          widget.destination.images[index],
                        ),
                      ),
                    ),
                    Column(
                      
                      children: [
                        const Spacer(),
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 100,
                              width: 100,
                              margin: const EdgeInsets.only(right: 10, bottom: 10),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Colors.white),
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.destination.images[
                                        (pageView + 1) % widget.destination.images.length],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.8),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.destination.images.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      height: 5,
                                      width: 20,
                                      margin: const EdgeInsets.only(right: 5),
                                      decoration: BoxDecoration(
                                        color: pageView == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.destination.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.white, size: 20),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "İzmir, Türkiye",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded,
                                              color: Colors.amber[800], size: 25),
                                          const SizedBox(width: 5),
                                          Text(
                                            widget.destination.rate.toString(),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Map Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openMapDialog(widget.destination.location.latitude,
                      widget.destination.location.longitude);
                },
                icon: const Icon(Icons.location_city, color: Colors.white),
                label: const Text(
                  "Konumu Haritada Göster",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Açıklama",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: blueTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.destination.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
