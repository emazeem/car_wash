import 'dart:io';

import 'package:carwash/constants.dart';
import 'package:carwash/model/User.dart';
import 'package:carwash/viewmodel/IndexViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';


// https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6


class HomeLocationScreen extends StatefulWidget {
  const HomeLocationScreen({Key? key}) : super(key: key);

  @override
  State<HomeLocationScreen> createState() => _HomeLocationScreenState();
}

const kGoogleApiKey = 'AIzaSyBgOM4iXth5olyb34-rcv9lbZsMcINhIvw';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _HomeLocationScreenState extends State<HomeLocationScreen> {

  Set<Marker> markersList = {};
  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;
  FocusNode focusNode = FocusNode();

  String? _currentAddress;
  final myController = TextEditingController();

  double lng = 0.0;
  double lat = 0.0;

  static CameraPosition initialCameraPosition = CameraPosition(target: LatLng(37.42796, -122.08574), zoom: 14.0);

  User? user;

  Future<void> _pullAuthUser() async {
    Provider.of<IndexViewModel>(context, listen: false).setUser(User());
    Provider.of<IndexViewModel>(context, listen: false).fetchUser();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _pullAuthUser();
    });
    User? user = Provider.of<IndexViewModel>(context, listen: false).getUser;

    if(user?.long!=null){
      double lat=double.parse('${user?.lat}');
      double long=double.parse('${user?.long}');
      initialCameraPosition = CameraPosition(target: LatLng( lat,long), zoom: 14.0);
      setState(() {
        markersList.add(
            Marker(
                markerId: const MarkerId("0"),
                position: LatLng(lat, long),
                infoWindow: InfoWindow(title: 'Location')
            )
        );
      });
    }
    _currentAddress=user?.address;
  }

  @override
  void dispose() {
    myController.dispose();
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IndexViewModel indexViewModel = Provider.of<IndexViewModel>(context);
    user = indexViewModel.getUser;

    return Scaffold(
      appBar: Const.appbar('Update Google Location'),
      body: Container(
          color: Const.primaryColor,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        _handlePressButton();
                      },
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 5,top: 10,left: 10,right: 10),
                        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade500
                            ),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Icon(Icons.search,color: Colors.grey,),
                              SizedBox(width: 10,),
                              Text(_currentAddress == null ?'Search your home location' :_currentAddress!,style: TextStyle(fontSize: 20,color: Colors.grey),),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                onPressed: () async {
                                  Map data = {
                                    'long': '${lng}',
                                    'lat': '${lat}',
                                    'user_id': '${user?.id}',
                                    'address': '${_currentAddress}',
                                  };
                                  try{
                                    dynamic response = await indexViewModel.updateLocation(data);
                                    Navigator.pop(context);
                                  }
                                  catch(e){
                                    Const.toastMessage('Something went wrong. Please try again.');
                                  }
                                },
                                child: const Text('Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GoogleMap(
                        initialCameraPosition: initialCameraPosition,
                        markers: markersList,
                        mapType: MapType.normal,
                        onMapCreated: (GoogleMapController controller) {
                          googleMapController = controller;
                        },
                        circles: Set.from([
                          Circle(
                            circleId: CircleId("1"),
                            center: LatLng(lat, lng),
                            radius: 1000, // 1000 meters
                            fillColor: Colors.blue.withOpacity(0.3),
                            strokeColor: Colors.blue,
                            strokeWidth: 2,
                          )
                        ]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        logo: SizedBox(),
        decoration: InputDecoration(
            hintText: 'Search your home location',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))
        ),
        components: [
          Component(Component.country, "pk"),
          Component(Component.country, "usa"),
        ]);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      Const.toastMessage(response.errorMessage!)
    );
  }

  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState) async {

    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey, apiHeaders: await const GoogleApiHeaders().getHeaders());
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;
    markersList.add(
        Marker(
            markerId: const MarkerId("0"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: detail.result.name)
        )
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    setState(() {
      print(p.description);
      print('p.description');
      _currentAddress= p.description;

    });
    googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 13.0));
  }
  Widget fakeInput(String title){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey.shade500
          ),
          borderRadius: BorderRadius.circular(5)
      ),
      child: Text(title,style: TextStyle(fontSize: 17),),
    );
  }

}
