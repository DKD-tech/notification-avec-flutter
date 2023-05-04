import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolt Notification',
      home: BoltNotification(),
    );
  }
}

class BoltNotification extends StatefulWidget {
  @override
  _BoltNotificationState createState() => _BoltNotificationState();
}

class _BoltNotificationState extends State<BoltNotification> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  late LatLng _carLocation;
  late Timer _timer;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late AndroidNotificationDetails _androidNotificationDetails;
  late NotificationDetails _notificationDetails;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _carLocation = LatLng(6.5244, 3.3792); // Initial location of the car
    _markers.add(
      Marker(
        markerId: MarkerId('car'),
        position: _carLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    _androidNotificationDetails = AndroidNotificationDetails(
      'vehicle_position_updates',
      'Vehicle Position Updates',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
    );
    _notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _carLocation = LatLng(
          _carLocation.latitude + 0.001,
          _carLocation.longitude + 0.001,
        ); // Update the location of the car
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('car'),
            position: _carLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ),
        );
        _showNotification();
      });
    });
  }

  Future<void> _showNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Vehicle Position',
      'Your vehicle is currently at (${_carLocation.latitude.toStringAsFixed(4)}, ${_carLocation.longitude.toStringAsFixed(4)})',
      _notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Your ride is on its way!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _carLocation,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}
