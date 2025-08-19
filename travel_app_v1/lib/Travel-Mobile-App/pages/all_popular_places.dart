import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/models/travel_model.dart';
import 'package:travel_app/Travel-Mobile-App/pages/place_detail.dart';
import 'package:travel_app/Travel-Mobile-App/pages/travel_home_screen.dart';
import 'package:travel_app/Travel-Mobile-App/widgets/popular_place.dart';


class SeeAllPopularPlacesPage extends StatefulWidget {
  const SeeAllPopularPlacesPage({super.key, required this.myDestination});
  final List<TravelPlaces> myDestination;

  @override
  State<SeeAllPopularPlacesPage> createState() => _SeeAllPopularPlacesPage();
}

class _SeeAllPopularPlacesPage extends State<SeeAllPopularPlacesPage> {

  @override
  Widget build(BuildContext context) {
    
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: appBarContents(context),
        body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.only(top: 20,bottom: 20),
                  child: Column(
                    children: List.generate(
                      widget.myDestination.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(
                          top: 10
                        ),
                        child: Align(
                          alignment:  Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailScreen(
                                    destination: widget.myDestination[index],
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
                ),
      );
  
  }
  AppBar appBarContents(BuildContext context){
    return AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 64,
        leading: GestureDetector(
          onTap: () {
           // Navigator.pop(context);
           TravelHomeScreen();
           Navigator.push(context,
            MaterialPageRoute(builder: (context)=>TravelHomeScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Popüler Yerler",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
       
      );
  }
}