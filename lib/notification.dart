import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'main.dart';

// class NotificationManager {
//   NotificationManager() {
//     _initialize();
//   }
// }

// creation d'une fonction qui va nous permettre d'afficher la notification lors de la simulation de maps
Future<void> showMapNotification(BuildContext context,
    {GoogleMapController? controller,
    int progress = 0,
    int maxProgress = 0,
    bool lineProgress = false}) async {
  // Configurer les options de notification de la plateforme android dans la variable androidPlatformChannelSpecifics
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'ChannelId',
    'ChannelName',
    importance: Importance.max,
    priority: Priority.high,
    showProgress: lineProgress,
    progress: progress,
    maxProgress: 100,
  );

  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Affichage de la notification. notificationPluging.show() va nous permettre d'afficher la notification avec un titre,
  //un corps de notification et les options de notification définies
  notificationPluging.show(
    0,
    'Trajet en temps réel',
    'Vous êtes en train de naviguer sur la carte.',
    platformChannelSpecifics,
  );
}

// Future<Uint8List?> captureMap(GoogleMapController controller) async {
//   // Récupérer la capture d'écran de la carte miniature.
//   final imageBytes = await controller.takeSnapshot();
//   final uiImage = await loadImage(imageBytes!);

//   // Convertir la capture d'écran en bytes.
//   final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
//   final pngBytes = byteData!.buffer.asUint8List();

//   return pngBytes;
// }

// Future<ui.Image> loadImage(Uint8List bytes) async {
//   final codec = await ui.instantiateImageCodec(bytes);
//   final frame = await codec.getNextFrame();
//   return frame.image;
// }
