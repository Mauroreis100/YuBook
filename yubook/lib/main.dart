import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/pages/admin/business_list.dart';
import 'package:yubook/pages/admin/userManager.dart';

import 'firebase_options.dart';
import 'theme/light_mode.dart';
import 'theme/dark_mode.dart';

import 'package:yubook/pages/loginpage.dart';
import 'package:yubook/pages/registerpage.dart';
import 'package:yubook/pages/usertype.dart';
import 'package:yubook/pages/home_page.dart';
import 'package:yubook/pages/admin/admin_dashboard.dart';
import 'package:yubook/pages/manager/manager_dashboard_page.dart';
import 'package:yubook/pages/manager/add_service_form.dart';
import 'package:yubook/pages/manager/services_page.dart';
import 'package:yubook/pages/manager/confirm_bookings_page.dart';
import 'package:yubook/pages/user/booking_history_page.dart';
import 'package:yubook/pages/user/booking_page.dart';
import 'package:yubook/pages/add_business_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return LoginPage(onTap: () {});

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final tipo = doc['tipoUser']?.toString().toLowerCase();

    if (tipo == 'admin') return const SuperAdminDashboardPage();
    if (tipo == 'gestor') return const ManagerDashboardPage();
    if (tipo == 'Cliente') return  HomePage();

    return HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YuBook',
          theme: lightMode,
          darkTheme: darkMode,
          home: snapshot.data!,
          routes: {
            '/loginpage': (context) => LoginPage(onTap: () {}),
            '/register': (context) => RegisterPage(onTap: () {}),
            '/usertype': (context) => UserTypePage(),
            '/home_page': (context) => HomePage(),
            '/admin_dashboard': (context) => const SuperAdminDashboardPage(),
            '/manager_dashboard': (context) => const ManagerDashboardPage(),
            '/add_service_form': (context) => AddServicePage(),
            '/services_page': (context) => BusinessServicesPage(),
            '/add_business_form': (context) => AddBusinessFormPage(),
            '/booking_history': (context) => BookingHistoryPage(),
            '/booking_page': (context) => const ClientAgendamentosPage(),
            '/confirm_bookings_page': (context) => const ManagerAgendamentosPage(),
            '/userManager': (context) => const UserManagerPage(),
            '/business_list': (context) => const AdminEmpresaListPage(),
          },
        );
      },
    );
  }
}
