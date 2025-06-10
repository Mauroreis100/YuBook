import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/custom_drawer.dart';
import 'package:yubook/pages/user/service_list_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/loginpage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Usuário não encontrado.')),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final tipoUser = data?['tipoUser']?.toString() ?? '';
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Home',
              style: GoogleFonts.chewy(color: Color(0xFF1976D2), fontSize: 28),
            ),
            iconTheme: IconThemeData(color: Color(0xFF1976D2)),
            elevation: 2,
          ),
          drawer: CustomDrawer(tipoUser: tipoUser),
          body: ServiceListPage(tipoUser: tipoUser),
        );
      },
    );
  }
}
