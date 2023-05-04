import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:iavc_notification/notification.dart';
import 'package:iavc_notification/param.dart';
import 'package:location/location.dart';

// Creation du widget de la class PageAccueil
class PageAccueil extends StatefulWidget {
  const PageAccueil({Key? key}) : super(key: key);

  @override
  _PageAccueilState createState() => _PageAccueilState();
}

class _PageAccueilState extends State<PageAccueil> {
  // Nous allons creer une instance  Completer permettant de signaler la fin de l'initialisation de GoogleMapController et de le controler
  Completer<GoogleMapController> _controller = Completer();

// Nous allons instantier par defaut le pointr de depart et de destination sur maps
//  LatLing represente nos coordonnées qui preneront en paramètre la latitude et la longitude
  static const LatLng sourceLocation = LatLng(49.8869994, 2.2933316);
  static const LatLng destination = LatLng(49.8978432, 2.3005744);

  // Nous allons créer une liste permettant de stocker les informations géographiques lors d'un trajet

  List<LatLng> polylineCoordinates = [];

  // creation d'une variable currentLocation afin de pouvoir suivre la position actuelle de l'utilisateur
  LocationData? currentLocation;
  double totalDistance = 0;

// Les variables initialiser à zero afin  de pouvoir calculer la distance parcourrue
//
  double pross = 0;

  // permettant de suivre et calculer l'etat d'avancement de notre bar par rapport au map
  double interPross = 0.0;

  // la distance parcourue lors du déplacement
  double distanceParcourue = 0;

  @override
  // Initialisation de l'emplacement actuel  de l'utilisateur en faisant appel aux differents méthodes
  void initState() {
    super.initState();

    // methode de recupération de la location
    _getCurrentLocation();

    // La recuperation des points polyline pour tracé le chemin du depart à la destination en utilisant le packages polyline
    _getPolylinePoints();
  }

  // Fonction utilisant l'API géolocalisateur pour recuperer la position actruelle de l'utilisateur

  Future<void> _getCurrentLocation() async {
    // recuperation les données de localisation de l'utilisateur
    Location location = Location();
    LocationData? locationData = await location.getLocation();
    currentLocation = locationData;

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((LocationData locationData) {
      currentLocation = locationData;
      print("locationData: $locationData");

// googlemapController permettant de contrôler la carte et de la mettre à jour dynamiquement avec la position actuelle de l'utilisateur.

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

// La mis en place du  calcul distance  qui separe la position actuelle de la destination et la destinateur
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

      interPross = (totalDistance - distanceParcourue);

//  Nous essayons de convertir la valeur  latitude en multipliant par 1000 ou 100
      print("distance: ${distance * 1000}");

      pross = (distanceParcourue / totalDistance) * 100;

      // Afficher dans le terminal pour s'assurer du bon fonctionnement
      print('totalDistance: ${totalDistance}');
      print('distanceParcourue: ${distanceParcourue}');
      print('pross: $pross\ninterPross: $interPross');

      // Utilisons la methode qui a été crée  dans notifications afin d'afficher la barre de progression et le contenu de notre boite de message

      showMapNotification(
        context,
        lineProgress: true,
        // progress: interPross.toInt(),
        progress: interPross.toInt(),
        maxProgress: 100,
      );

      setState(() {});
    });
  }

// La formules  qui utilise les coordonnées de deux points géographiques (latitude et longitude) et renvoie la
// distance (en kilomètres)
// entre ces deux points en utilisant la formule de la distance orthodromique sur une sphère

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
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

// Cette bouble nous permet de tenir compte de la courbure du trajet de l'utilisateur en utilisant les coordonées polylines
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
        // Point de marquage sur le map
        markers: {
          const Marker(markerId: MarkerId("source"), position: sourceLocation),
          const Marker(markerId: MarkerId("destination"), position: destination)
        },

        // Notre package polylines  qui va nous  permettrent de tracer une ligne entre le currentLocation et la Destination
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

        // La mise en jour de la position camera
        onCameraMove: (CameraPosition position) {
          double distance = _calculateDistance(
              position.target.latitude,
              position.target.longitude,
              destination.latitude,
              destination.longitude);
          interPross = ((totalDistance - distanceParcourue) * 100);
        },
      ),
    );
  }
}
