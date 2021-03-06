import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/components/address_content.dart';
import 'package:uber_clone/components/collectFareDialog.dart';
import 'package:uber_clone/components/noDriverAvailableDialog.dart';
import 'package:uber_clone/components/progress_dialogue.dart';
import 'package:uber_clone/models/direction_details.dart';
import 'package:uber_clone/models/nearbyAvailableDrivers.dart';
import 'package:uber_clone/provider/app_data.dart';
import 'package:uber_clone/provider/app_state.dart';
import 'package:uber_clone/screens/rating_screen.dart';
import 'package:uber_clone/screens/search_screen.dart';
import 'package:uber_clone/services/geoFireAssistant.dart';
import 'package:uber_clone/services/methods.dart';
import 'package:uber_clone/utils/app.dart';
import 'package:uber_clone/utils/config_map.dart';
import 'package:uber_clone/widgets/drawer_widget.dart';
import 'package:uber_clone/widgets/ride_request.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home';
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(9.1526728, 105.1960795),
    zoom: 14.4746,
  );

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double bottomPaddingOfMap = 0;
  static double rideDetailsContainerHeight = 0;
  static double searchContainerHeight = 300.0;
  static double requestRideContainerHeight = 0;
  static double driverDetailsContainerHeight = 0;
  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  Completer<GoogleMapController> _googleMapController = Completer();

  GoogleMapController? newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;
  DirectionDetails? time;


  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markers = {};
  Set<Circle> circles = {};
  static BitmapDescriptor nearbyIcon = BitmapDescriptor.defaultMarker;
  Position? currentPosition;
  List<NearbyAvailableDrivers>? availableDrivers;
  String state ='normal';
  StreamSubscription<Event>? rideStreamSubscription;
  bool isRequestingPositionDetails = false;





//  hi???n th??? t??m ki???m
  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 300.0;
      bottomPaddingOfMap = 320.0;
      drawerOpen = false;
    });
  }
//  hi???n th??? chi ti???t ?????t xe
  void displayRequestDetailsContainer() {
    setState(() {
      requestRideContainerHeight = 250;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }
//  hi???n th??? th??ng tin t??i x???
  void displayDriverDetailsContainer(){
    setState(() {
      requestRideContainerHeight = 0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 2900.0;
      driverDetailsContainerHeight = 310.0;
    });
  }
// v??? tr?? hi???n t???i + gps
  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 14.0);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await Methods.searchCoordinateAddress(position, context);
    print("????y l?? ?????a ch??? c???a b???n:" + address);

    initGeoFireListner();


  }
// v??? tr?? hi???n t???i ?????n ??i???m ch???n
  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider
            .of<AppData>(context, listen: false)
            .pickUpLocation;
    var finalPos = Provider
        .of<AppData>(context, listen: false)
        .dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
      const ProgressDialogue(message: 'Vui l??ng ?????i...'),
    );

    var details =
    await Methods.getPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details!;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointResult =
    polylinePoints.decodePolyline(details!.encodedPoints);

    pLineCoordinates.clear();
    if (decodePolylinePointResult.isNotEmpty) {
      for (var pointLatLng in decodePolylinePointResult) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('PolylineID'),
        color: Colors.red,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    late LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: dropOffLatLng,
          northeast: pickUpLatLng);
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
      );
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
      );
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      markerId: MarkerId('pickUpId'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
      InfoWindow(title: initialPos.placeName, snippet: 'My location'),
      position: pickUpLatLng,
    );
    Marker dropOffLocMarker = Marker(
      markerId: MarkerId('dropOffId'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
      InfoWindow(title: finalPos.placeName, snippet: 'Drop off location'),
      position: dropOffLatLng,
    );
    setState(() {
      markers.add(pickUpLocMarker);
      markers.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      circleId: CircleId('pickUpId'),
      fillColor: Colors.red,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
    );
    Circle dropOffLocCircle = Circle(
      circleId: CircleId('dropOffId'),
      fillColor: Colors.red,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
    );
    setState(() {
      circles.add(pickUpLocCircle);
      circles.add(dropOffLocCircle);
    });
  }
// kh???i ?????ng l???i ???ng d???ng
  resetApp() {
    setState(() {
      drawerOpen = true;

      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 240.0;
      polylineSet.clear();
      markers.clear();
      circles.clear();
      pLineCoordinates.clear();

      statusRide = "";
      driverName = "";
      driverphone = "";
      carDetailsDriver = "";
      rideStatus = "Xe ??ang ?????n ????n";
      driverDetailsContainerHeight = 0.0;
    });
    locatePosition();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Methods.getOnlineUserInformation();
  }
// l??u d??? li???u l??n firebase
  void saveRideRequest() {
    usersRef =
        FirebaseDatabase.instance.reference().child('Ride Requests').push();
    var pickUp = Provider
        .of<AppData>(context, listen: false)
        .pickUpLocation;
    var dropOff = Provider
        .of<AppData>(context, listen: false)
        .dropOffLocation;

    Map pickUpLocMap = {
      'latitude': pickUp!.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      'latitude': dropOff!.latitude.toString(),
      'longitude': dropOff.longitude.toString(),
    };
    Map rideInfoMap = {
      'driver_id': 'waiting',
      'payment_method': 'cash',
      'pickup': pickUpLocMap,
      'dropoff': dropOffLocMap,
      'created_at': DateTime.now().toString(),
      'rider_name': userCurrentInfo!.name,
      'rider_phone': userCurrentInfo!.phone,
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOff.placeName,
      'ride_type': carRideType,
    };



    usersRef!.set(rideInfoMap);
    rideStreamSubscription = usersRef!.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }

      if(event.snapshot.value['car_details'] != null)
      {
        setState(() {
          carDetailsDriver = event.snapshot.value['car_details'].toString();
        });
      }
      if(event.snapshot.value['driver_name'] != null)
      {
        setState(() {
          driverName = event.snapshot.value['driver_name'].toString();
        });
      }
      if(event.snapshot.value['driver_phone'] != null)
      {
        setState(() {
          driverphone = event.snapshot.value['driver_phone'].toString();
        });
      }

      if(event.snapshot.value['driver_location'] != null)
      {
        double driverLat = double.parse(event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverCurrentPosition = LatLng(driverLat, driverLng);

        if(statusRide == 'accepted')
        {
          updateRideTimeToPickUpLoc(driverCurrentPosition);
        }
        else if(statusRide == 'onride')
        {
          updateRideTimeToDropOffLoc(driverCurrentPosition);
        }
        else if(statusRide == 'arrived')
        {
          setState(() {
            rideStatus = "Xe ???? ?????n";
          });
        }
      }

      if(event.snapshot.value['status'] != null)
      {
        statusRide = event.snapshot.value['status'].toString();
      }
      if(statusRide == 'accepted')
      {
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeofileMarkers();
      }
      if(statusRide == 'ended')
      {
        if(event.snapshot.value["fares"] != null)
        {
          int fare = int.parse(event.snapshot.value["fares"].toString());
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context)=> CollectFareDialog(paymentMethod: "cash", fareAmount: fare,),
          );

          String driverId = "";
          if(res == 'close')
          {
            if(event.snapshot.value['driver_id'] != null)
            {
              driverId = event.snapshot.value['driver_id'].toString();
            }

            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RatingScreen(driverId: driverId)));


            usersRef!.onDisconnect();
            usersRef = null;
            rideStreamSubscription!.cancel();
            rideStreamSubscription = null;
            resetApp();
          }
        }
      }

    });
  }



// x??a ??i???m ????nh d???u
  void deleteGeofileMarkers()
  {
    setState(() {
      markers.removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }
// t??nh to??n th???i gian khi xe ??ang t???i
  void updateRideTimeToPickUpLoc(LatLng driverCurrentPosition) async {
    if(isRequestingPositionDetails == false)
    {
      isRequestingPositionDetails = true;


      var positionUserLatLng = LatLng(currentPosition!.latitude, currentPosition!.longitude);
      var details = await Methods.getPlaceDirectionDetails(driverCurrentPosition, positionUserLatLng);
      if (details == null)
      {
        return;
      }
      setState(() {
        rideStatus = "Xe ??ang t???i trong " + details.durationText;
      });

      isRequestingPositionDetails = false;
    }
  }
// t??nh to??n th???i gi??n khi ??ang ?????n ?????a ??i???m
  void updateRideTimeToDropOffLoc(LatLng driverCurrentPosition) async {
    if(isRequestingPositionDetails != null)
    {
      isRequestingPositionDetails = true;


      var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;
      var dropOffUserLatLng = LatLng(dropOff!.latitude, dropOff.longitude);
      var details = await Methods.getPlaceDirectionDetails(driverCurrentPosition, dropOffUserLatLng);
      if (details == null)
      {
        return;
      }
      setState(() {
        rideStatus = "??ang ??i t???i ?????a ??i???m trong " + details.durationText;
      });

      isRequestingPositionDetails = false;
    }
  }
// h???y chuy???n ??i
  void cancelRideRequest() {
    usersRef!.remove();
    setState(() {
      state = 'normal';
    });
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      key: scaffoldKey,

      drawer: Container(
        color: Colors.white,
        width: 230.0,
        child: const DrawerWidget(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: markers,
            circles: circles,
            polylines: polylineSet,
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            initialCameraPosition: HomeScreen._kGooglePlex,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 240.0;
              });
              locatePosition();
              //appState.locatePosition(context);
            },
          ),
          // menu
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: (

                  ) {
                if (drawerOpen) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
// home table
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: -60.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6.0,),
                      const Text(
                        'Xin ch??o, ch??c b???n m???t ng??y t???t l??nh!',
                        style: TextStyle(
                          fontSize: 15.0,
                            fontFamily: 'OpenSans'
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      const Text(
                        'B???n mu???n ??i ????u?',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'OpenSans'
                          ,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0,),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchScreen()));

                          if (res == 'getDirection') {
                            displayRideDetailsContainer();
                            //await getPlaceDirection();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text('T??m ki???m'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0,),
                      AddressContent(
                        icon: Icons.home,

                        locationAddress:
                        Provider.of<AppData>(context).pickUpLocation != null ? Provider.of<AppData>(context).pickUpLocation!.placeName : 'Add Home',
                        locationDescripton: 'V??? tr?? hi???n t???i c???a b???n',
                      ),
                      const SizedBox(height: 10.0,),

                    ],
                  ),
                ),
              ),
            ),
          ),
// request table
          Positioned(
            child: AnimatedSize(
              //vsync: this,
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26.0),
                    topRight: Radius.circular(26.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(

                  padding: const EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //CMBike
                      GestureDetector(
                        onTap: ()
                        {
                          Fluttertoast.showToast(msg: "??ang t??m ki???m CMBike....",);
                          setState(() {
                            state = "requesting";
                            carRideType = "CMBike";
                          });
                          displayRequestDetailsContainer();
                          availableDrivers = GeoFireAssistant.nearByAvailableDriversList;
                          searchNearestDriver();
                        },
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/bike.png',
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Xe 2 b??nh',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'bolt-semibold',
                                      ),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails!.distanceText
                                          : ''),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'bolt-semibold',
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails!.durationText
                                          : ''),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'bolt-semibold',
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Text(
                                  ((tripDirectionDetails != null)
                                      ? NumberFormat.currency(locale: 'vi', decimalDigits: 0).format(Methods.calculateFares(tripDirectionDetails!)):''),
                                  style: const TextStyle(fontFamily: 'bolt-semibold'),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      const SizedBox(height: 10.0,),

                      //CMCar
                      GestureDetector(
                        onTap: ()
                        {
                          Fluttertoast.showToast(msg: "??ang t??m ki???m xe CMCar....",);
                          setState(() {
                            state = "requesting";
                            carRideType = "CMCar";
                          });
                          displayRequestDetailsContainer();
                          availableDrivers = GeoFireAssistant.nearByAvailableDriversList;
                          searchNearestDriver();
                        },

                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/Car_small.png',
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Xe 4 b??nh',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'bolt-semibold',
                                      ),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails!.distanceText
                                          : ''),

                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'bolt-semibold',
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    Text(
                                      ((tripDirectionDetails != null)
                                          ? tripDirectionDetails!.durationText
                                          : ''),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: 'bolt-semibold',
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Container(),
                                ),
                                Text(
                                  ((tripDirectionDetails != null)
                                      ? NumberFormat.currency(locale: 'vi', decimalDigits: 0).format(Methods.calculateFares(tripDirectionDetails!)*2):''),
                                  style: const TextStyle(fontFamily: 'bolt-semibold'),
                                ),

                              ],
                            ),
                          ),

                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      const SizedBox(height: 10.0,),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: const [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 13.0,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Text('Thanh to??n tr???c ti???p'),
                            SizedBox(
                              width: 6.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            right: 0.0,
            bottom: 0.0,
            left: 0.0,
          ),


          RideRequest(
            requestRideContainerHeight: requestRideContainerHeight,
            resetOnpressed: resetApp,
            cancelOnPressed: cancelRideRequest,
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    color: Colors.black,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: driverDetailsContainerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Text(rideStatus, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bolt"),),

                      ],
                    ),

                    SizedBox(height: 22.0,),

                    Divider(height: 2.0, thickness: 2.0,),

                    SizedBox(height: 22.0,),

                    Text(carDetailsDriver, style: TextStyle(color: Colors.grey),),

                    Text(driverName, style: TextStyle(fontSize: 20.0),),

                    SizedBox(height: 22.0,),

                    Divider(height: 2.0, thickness: 2.0,),

                    SizedBox(height: 22.0,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                  onPressed: () async
                  {
                    launch(('tel://${driverphone}'));
                  },
                  color: Colors.black87,
                  child: Padding(
                      padding: EdgeInsets.all(17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("G???i cho t??i x???   ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                          Icon(Icons.call, color: Colors.white, size: 26.0,),
                        ],
                      ),
                  ),
                ),
                    ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
// kh???i t???o geofire
  void initGeoFireListner() {
    Geofire.initialize("availableDrivers");
    //comment
    Geofire.queryAtLocation(
        currentPosition!.latitude, currentPosition!.longitude, 15)!.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList.add(nearbyAvailableDrivers);
            if(nearbyAvailableDriverKeysLoaded == true)
            {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers = NearbyAvailableDrivers();
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            //nearbyAvailableDriverKeysLoaded = true;
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
    //comment
  }
// hi???n th??? t??i x??? tr??n b???n ????? khi t??i x??? online
  void updateAvailableDriversOnMap() {
    setState(() {
      markers.clear();
    });

    Set<Marker> tMakers = Set<Marker>();
    for(NearbyAvailableDrivers driver in GeoFireAssistant.nearByAvailableDriversList)
    {
      LatLng driverAvaiablePosition = LatLng(driver.latitude!, driver.longitude!);
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvaiablePosition,
        icon: nearbyIcon,
        rotation: Methods.createRandomNumber(360),
      );

      tMakers.add(marker);
    }
    setState(() {
      markers = tMakers;
    });
  }
// t???o bi???u t?????ng xe cho t??i x???
  void createIconMarker()
  {
    if (nearbyIcon == BitmapDescriptor.defaultMarker) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, "assets/images/car-android.png")
          .then((value) => nearbyIcon = value);
    }
  }
// tr??? v??? th??ng b??o khi kh??ng c?? t??i x??? n??o g???n ????y
  void noDriverFound()
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverAvailableDialog()
    );
  }
// h??m t??m ki???m t??i x???
  void searchNearestDriver()
  {
    if(availableDrivers!.length == 0)
    {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers![0];

    driverRef.child(driver.key!).child("car_details").child("type").once().then((DataSnapshot snap) async
    {
      if(await snap.value != null)
      {
        String carType = snap.value.toString();
        if(carType == carRideType)
        {
          notifyDriver(driver);
          availableDrivers!.removeAt(0);
        }
        else
        {
          Fluttertoast.showToast(msg: carRideType + ' kh??ng c?? th???c. Vui l??ng th??? l???i.',);
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Kh??ng tim th???y xe, vui l??ng th??? l???i.",);
      }
    });

    print(driver.key);
  }



// th??ng b??o khi c?? t??i x??? ??? g???n v?? x??? l?? qu?? h???n th???i gian t??m xe
  void notifyDriver(NearbyAvailableDrivers driver)
  {
    DatabaseReference DriversRef = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${driver.key}/newRide');
    DriversRef.set(usersRef!.key);

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('Drivers/${driver.key}/token');

    tokenRef.once().then((DataSnapshot snapshot){
      if (snapshot.value != null)
      {
        String token = snapshot.value.toString();

        Methods.sendNotificationToDriver(
            token, context, usersRef!.key);
      }

      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        // k???t th??c th???i gian t??m ki???m khi y??u c???u chuy???n ??i b??? h???y;
        if (state != 'requesting') {
          DriversRef.set('cancelled');
          DriversRef.onDisconnect();
          driverRequestTimeout = 30;
          timer.cancel();
        }

        driverRequestTimeout --;

        // Khi c?? t??i x??? ch???p nh???n y??u c???u chuy???n ??i
        DriversRef.onValue.listen((event) {
          // Khi t??i x??? b???m ch???p nh???n cho chuy???n ??i
          if (event.snapshot.value.toString() == 'accepted') {
            DriversRef.onDisconnect();
            driverRequestTimeout = 30;
            timer.cancel();
          }
        });
        if (driverRequestTimeout == 0) {
          //????a th??ng tin cho t??i x??? khi y??u c???u chuy???n ??i h???t h???n
          DriversRef.set('timeout');
          DriversRef.onDisconnect();
          driverRequestTimeout = 30;
          timer.cancel();

          //Ti???p t??c t??m ki???m xe kh??c
          searchNearestDriver();
        }
      });
    });
  }
}
