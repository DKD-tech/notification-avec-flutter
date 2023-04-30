import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:iavc_notification/notification.dart';
import 'package:iavc_notification/param.dart';
import 'package:location/location.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({super.key});

  @override
  PageAccueilState createState() => PageAccueilState();
}

class PageAccueilState extends State<PageAccueil> {
  // final String title;
  //final String completer;

  //Map<PolylineId, Polyline> polylines = {};

  final Completer<GoogleMapController> _controller = Completer();

  // static final CameraPosition initialilLocatioin = CameraPosition(target:LatLng(laltitude,longitude), zoom: 14.5)

/**
 * Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("../assets/exple.png");
    return byteData.buffer.asUint8List();
  }
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    setState(() {
      Marker(
          markerId: MarkerId("home"),
          position: latLng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latLng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }
*/
  static const LatLng sourceLocation = LatLng(49.8869994, 2.2933316);
  static const LatLng destination = LatLng(49.8978432, 2.3005744);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  //BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  //BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  //BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

//recuperation de la localisation
  int pross = 0;
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    //Ecouter le changement de position
    location.onLocationChanged.listen((trajet) {
      currentLocation = trajet;

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 13.5, target: LatLng(trajet.latitude!, trajet.longitude!)),
      ));
      var diff = ((destination.latitude - trajet.latitude!) * 10000000).toInt();
      //  print("diff $diff; ${(destination.latitude * 10000000).toInt()}");
      // print((destination.latitude - trajet.latitude!));
      // Afficher la notification de la carte en miniature
      print('pross $pross');
      showMapNotification(context, googleMapController,
          lineProgress: true, progress: pross++, maxProgress: 100);

      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.latitude));

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );

      setState(() {});
    }
  }

  //void setEndMarkerIcon() {
  //// BitmapDescriptor.fromAssetImage(
  ////        ImageConfiguration.empty, "assets/exple.png")
  ////    .then((icon) => sourceIcon = icon);
  //// BitmapDescriptor.fromAssetImage(
  ////        ImageConfiguration.empty, "assets/exple.png")
  ////   .then((icon) => destinationIcon = icon);
  ////BitmapDescriptor.fromAssetImage(
  ////    ImageConfiguration.empty, "assets/exple.png")
  ////  .then((icon) => currentLocationIcon = icon);
  // }

  @override
  void initState() {
    getCurrentLocation();
    //getMarker();
    //// setEndMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: Text(""))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 13.5),
              markers: {
                Marker(
                    markerId: const MarkerId("currentLocation"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                    ////  icon: currentLocationIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                const Marker(
                    markerId: MarkerId("source"), position: sourceLocation),
                const Marker(
                    markerId: MarkerId("destination"), position: destination)
              },
              onMapCreated: (controller) {
                //passer le googleController default a  et mettre à jour la postition de la camera sur la carte
                _controller.complete(controller);
              },
              polylines: {
                Polyline(
                    polylineId: const PolylineId("route"),
                    points: polylineCoordinates,
                    color: const Color(0xFF7B61FF),
                    width: 6),
              },
            ),
    );
  }
}
