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
import 'package:yubook/pages/manager/add_service_form.dart';
import 'package:yubook/pages/manager/confirm_bookings_page.dart';
import 'package:yubook/pages/user/booking_history_page.dart';
import 'package:yubook/pages/user/booking_page.dart';
import 'package:yubook/pages/add_business_form.dart';
import 'package:yubook/pages/perfil.dart';
import 'package:yubook/pages/users_page.dart';
import 'package:yubook/services/notification_service.dart';
import 'package:yubook/pages/manager/edit_service_page.dart';
import 'package:yubook/pages/manager/meus_servicos_page.dart';
import 'package:yubook/pages/user/service_details_page.dart';
import 'package:yubook/pages/manager/service_bookings_page.dart';
import 'package:yubook/pages/user/client_bookings_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yubook/pages/manager/admin_dashboard.dart';

final ThemeData yuBookTheme = ThemeData(
  primaryColor: const Color(0xFF619bfb),
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF619bfb),
    secondary: Color(0xFF7db4fc),
    background: Color(0xFFcffeff),
    error: Color(0xFFFF4F4F),
  ),
  textTheme: GoogleFonts.chewyTextTheme().copyWith(
    bodyMedium: GoogleFonts.chewy(color: Color(0xFF22223B)),
    titleLarge: GoogleFonts.chewy(fontSize: 24, color: Color(0xFF619bfb)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF619bfb),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.chewy(fontSize: 18),
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF619bfb)),
      borderRadius: BorderRadius.circular(12),
    ),
    labelStyle: GoogleFonts.chewy(color: Color(0xFF619bfb)),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return LoginPage(onTap: () {});

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (!doc.exists) {
      // Se o documento não existe, volta para login
      return LoginPage(onTap: () {});
    }
    // Todos os usuários vão para HomePage (lista geral de serviços)
    return HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Center(child: CircularProgressIndicator()),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YuBook',
          theme: yuBookTheme,
          home:
              snapshot.data ??
              const Center(child: Text('Erro ao carregar app')),
          routes: {
            '/loginpage': (context) => LoginPage(onTap: () {}),
            '/register': (context) => RegisterPage(onTap: () {}),
            '/usertype': (context) => UserTypePage(),
            '/home_page': (context) => HomePage(),
            '/admin_dashboard': (context) => const SuperAdminDashboardPage(),
            '/add_service_form': (context) => AddServicePage(),
            '/edit_service_form': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              final serviceId = args != null ? args['serviceId'] as String : '';
              return EditServicePage(serviceId: serviceId);
            },
            '/add_business_form': (context) => AddBusinessFormPage(),
            '/booking_history': (context) => BookingHistoryPage(),
            '/booking_page': (context) => const ClientAgendamentosPage(),
            '/confirm_bookings_page':
                (context) => const ManagerAgendamentosPage(),
            '/userManager': (context) => const UserManagerPage(),
            '/business_list': (context) => const AdminEmpresaListPage(),
            '/perfil': (context) => const PerfilPage(),
            '/users': (context) => const UsersPage(),
            '/meus_servicos': (context) => const MeusServicosPage(),
            '/service_details': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              final serviceId =
                  args != null ? args['serviceId'] as String : null;
              return ServiceDetailsPage();
            },
            '/service_bookings': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              final serviceId =
                  args != null ? args['serviceId'] as String : null;
              final serviceName =
                  args != null ? args['serviceName'] as String : '';
              return ServiceBookingsPage(
                serviceId: serviceId,
                serviceName: serviceName,
              );
            },
            '/client_bookings': (context) => const ClientBookingsPage(),
            '/manager_dashboard': (context) => const ManagerDashboardPage(),
          },
        );
      },
    );
  }
}
