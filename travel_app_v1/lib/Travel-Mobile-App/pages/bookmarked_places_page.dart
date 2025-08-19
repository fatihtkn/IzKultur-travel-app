import 'package:flutter/material.dart';
import 'package:travel_app/Travel-Mobile-App/const.dart';
import 'package:travel_app/Travel-Mobile-App/models/travel_model.dart';
import 'package:travel_app/Travel-Mobile-App/pages/place_detail.dart';
import 'package:travel_app/Travel-Mobile-App/widgets/popular_place.dart';



class BookmarkedPlacesPage extends StatefulWidget {
  const BookmarkedPlacesPage({super.key});

  @override
  State<BookmarkedPlacesPage> createState() => _BookmarkedPlacesPageState();
}

class _BookmarkedPlacesPageState extends State<BookmarkedPlacesPage> {

  List<TravelPlaces> bookmarkedPlaces =
      travelPlacesTest.where((element) => element.isBookmarked==true).toList();

  
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
                      bookmarkedPlaces.length,
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
                                    destination: bookmarkedPlaces[index],
                                  ),
                                ),
                              );
                            },
                            child: PopularPlace(
                              destination: bookmarkedPlaces[index],
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
        automaticallyImplyLeading : false,
        
        centerTitle: true,
        title: const Text(
          "Kaydedilen Yerler",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
       
      );
  }
  
}