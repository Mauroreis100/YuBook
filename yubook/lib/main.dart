import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yubook/pages/home_page.dart';
import 'package:yubook/pages/loginpage.dart';
import 'package:yubook/pages/add_business_form.dart';
import 'package:yubook/pages/manager/add_service_form.dart';
import 'package:yubook/pages/manager/services_page.dart';
import 'package:yubook/pages/registerpage.dart';
import 'package:yubook/pages/usertype.dart';
import 'package:yubook/theme/light_mode.dart';
import 'firebase_options.dart';
import 'theme/dark_mode.dart';
import 'pages/user/booking_history_page.dart';
import 'package:yubook/pages/manager/manager_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YuBook',
      theme: lightMode,
      darkTheme: darkMode,
      initialRoute: '/loginpage',
      routes: {
        '/': (context) => LoginPage(onTap: () {}),
        '/home_page': (context) => HomePage(),
        '/loginpage': (context) => LoginPage(onTap: () {}),
        '/register': (context) => RegisterPage(onTap: () {}),
        '/usertype': (context) => UserTypePage(),
        '/add_service_form': (context) => AddServicePage(),
        '/services_page': (context) => BusinessServicesPage(),
        //     '/bookingPage': (context) => BookingPage(),
        '/add_business_form': (context) => AddBusinessFormPage(),
        '/booking_history': (context) => BookingHistoryPage(),
        '/manager_dashboard': (context) => ManagerDashboardPage(),
      },
    );
  }
}
