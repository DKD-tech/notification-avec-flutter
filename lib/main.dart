import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'page_accueil.dart';
import 'package:workmanager/workmanager.dart';

// configuration du plugin de notification locale en flutter grace au package: flutter-local-notifications
FlutterLocalNotificationsPlugin notificationPluging =
    FlutterLocalNotificationsPlugin();

void main() async {
  // cette ligne va s'assurer que tous les widgets sont initialisé avant l'utilisation des plugin
  WidgetsFlutterBinding.ensureInitialized();

  //definition des plateformes android et Ios configurant le comportement de la notification
  const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");

  //L'instanciation  en configurant les paramètres d'andoid qui va nous  permettre d'initialiser la notification
  const notificationSetting = InitializationSettings(
    android: androidSettings,
  );

  await notificationPluging.initialize(notificationSetting);

  runApp(MyApp());
}

// Definition du widget contenant l'interface utilisateur de l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // le widget MaterialApp nous permet de construire l'interface utilisateur de laa classe Page_Accueil
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageAccueil(),
      debugShowCheckedModeBanner: false,
    );
  }
}
