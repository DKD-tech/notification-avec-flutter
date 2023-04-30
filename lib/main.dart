import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'page_accueil.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  //Pattern Singletonj
  // Workmanager().registerPeriodicTask(
  //   "2",
  //   "simplePeriodicTask",
  //   frequency: const Duration(minutes: 1),
  // );
  runApp(MyApp());
}

// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) {
//     FlutterLocalNotificationsPlugin local = FlutterLocalNotificationsPlugin();

//     const android = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     var settings = const InitializationSettings(android: android);

//     local.initialize(settings);

//     _showNotificationWithDefaultSound(local);

//     return Future.value(true);
//   });
// }

// Future _showNotificationWithDefaultSound(FlutterLocalNotificationsPlugin local,
//     {int maxProgress = 0, int progress = 0}) async {
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'channelId', 'channelName',
//       showProgress: true,
//       maxProgress: maxProgress,
//       progress: progress,
//       importance: Importance.max,
//       priority: Priority.high);

//   var platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);

//   await local.show(0, 'Titre', 'Corps', platformChannelSpecifics,
//       payload: 'Default_Sound');
// }

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

/**
 * 
 */