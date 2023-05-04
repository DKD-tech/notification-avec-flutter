import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:iavc_notification/notification.dart';
import 'package:iavc_notification/param.dart';
import 'package:location/location.dart';

class PageAccueil extends StatefulWidget {
  const PageAccueil({Key? key}) : super(key: key);

  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(49.8869994, 2.2933316);
  static const LatLng destination = LatLng(49.8978432, 2.3005744);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  double totalDistance = 0;

  double pross = 0;
  double interPross = 0.0;
  double distanceParcourue = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getPolylinePoints();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    LocationData? locationData = await location.getLocation();
    currentLocation = locationData;

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData locationData) {
      currentLocation = locationData;
      print("locationData: $locationData");

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
          ),
        ),
      );

      double distance = _calculateDistance(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        destination.latitude,
        destination.longitude,
      );
      totalDistance += distance;

      distanceParcourue = _calculateDistance(
        sourceLocation.latitude,
        sourceLocation.longitude,
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      );
      // if (distance < 0.02) {
      //   // Arreter la notification
      // } else {
      //   var distanceParcourue = currentLocation != null
      //       ? _calculateDistance(
      //           currentLocation!.latitude!,
      //           currentLocation!.longitude!,
      //           destination.latitude,
      //           destination.longitude,
      //         )
      //       : 0.0;
      interPross = (totalDistance - distanceParcourue);

      print("distance: ${distance * 1000}");
      // if (distance <= 0) {
      //   removeNotification();

      // }
      pross = (distanceParcourue / totalDistance) * 100;
      print('totalDistance: ${totalDistance}');
      print('distanceParcourue: ${distanceParcourue}');
      // print('interPross: ${interPross * 1000}');
      // difference
      // interPross = (totalDistance - distance).toInt() * 1000;
      // interPross = totalDistance.toInt() - pross;

      print('pross: $pross\ninterPross: $interPross');

      showMapNotification(
        context,
        lineProgress: true,
        // progress: interPross.toInt(),
        progress: pross.toInt(),
        maxProgress: 100,
      );

      setState(() {});
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    double p = 0.017453292519943295;
    double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Future<void> _getPolylinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    // double remainingDistance = _calculateDistance(
    //   currentLocation!.latitude!,
    //   currentLocation!.longitude!,
    //   destination.latitude,
    //   destination.longitude,
    // );
    // totalDistance = remainingDistance;

// Cette bouble nous permet de tenir compte de la courbure du trajet de l'utilisateur
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      double segmentDistance = _calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
      totalDistance += segmentDistance;
    }

    setState(() {});
  }

  // void removeNotification() {
  //   // Appeler la méthode fournie par le package iavc_notification pour supprimer la notification
  //   NotificationManager.removeNotification();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Accueil'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: sourceLocation,
          zoom: 13.5,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          ),
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _getPolylinePoints();
        },
        onCameraMove: (CameraPosition position) {
          double distance = _calculateDistance(
              position.target.latitude,
              position.target.longitude,
              destination.latitude,
              destination.longitude);
          interPross = ((totalDistance - distance) * 100);
        },
      ),
    );
  }
}
