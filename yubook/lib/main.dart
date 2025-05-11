import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yubook/auth/auth.dart';
import 'package:yubook/pages/home_page.dart';
import 'package:yubook/pages/loginpage.dart';
import 'package:yubook/pages/registerpage.dart';
import 'package:yubook/pages/usertype.dart';
import 'package:yubook/theme/light_mode.dart';
import 'firebase_options.dart';
import 'theme/dark_mode.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/home_page': (context) => HomePage(),
        '/loginpage': (context) => LoginPage(onTap: () {  },),
        '/register': (context) => RegisterPage(onTap: () {  },),
        '/usertype': (context) => UserTypePage(),
      },
    );

  }

}

