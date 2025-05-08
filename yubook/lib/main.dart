import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yubook/theme/light_mode.dart';
import 'firebase_options.dart';
import 'pages/LoginPage.dart';
import 'theme/light_mode.dart';
import 'theme/dark_mode.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  Widget build(BuildContext context){
    return MaterialApp(
      debugShowMaterialGrid: false,
      home: LoginPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );

  }

}

