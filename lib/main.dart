import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'page_accueil.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "2",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
  );
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    FlutterLocalNotificationsPlugin local =
        new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');

    var settings = new InitializationSettings(android: android);

    local.initialize(settings);

    _showNotificationWithDefaultSound(local);

    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(local) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'ROMAIN', 'Trajet',
      importance: Importance.max, priority: Priority.high);

  var platformChannelSpecifics =
      new NotificationDetails(android: androidPlatformChannelSpecifics);

  await local.show(0, '', '', platformChannelSpecifics,
      payload: 'Default_Sound');
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //useMaterial3: true,
      ),
      home: PageAccueil(),
      debugShowCheckedModeBanner: false,
    );
  }
}
