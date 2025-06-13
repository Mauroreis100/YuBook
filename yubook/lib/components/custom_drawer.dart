import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomDrawer extends StatelessWidget {
  final String tipoUser;
  final VoidCallback? onLogout;

  const CustomDrawer({Key? key, required this.tipoUser, this.onLogout})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'YUBOOK',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1976D2),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  tileColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  leading: Icon(
                    Icons.home_rounded,
                    color: Color(0xFF1976D2),
                    size: 34,
                  ),
                  title: Text(
                    'Home',
                    style: GoogleFonts.chewy(
                      color: Color(0xFF1565C0),
                      fontSize: 22,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/home_page');
                  },
                ),
                if (tipoUser == 'admin') ...[
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.apartment_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'Negócios',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/business_list');
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.groups_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'User Manager',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/userManager');
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'Dashboard',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin_dashboard');
                    },
                  ),
                ] else if (tipoUser == 'gestor') ...[
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.design_services_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'Meus Serviços',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/meus_servicos');
                    },
                  ),
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.analytics_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'Dashboard',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/manager_dashboard');
                    },
                  ),
                ] else if (tipoUser == 'cliente' || tipoUser == 'Cliente') ...[
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.event_available_rounded,
                      color: Color(0xFF1976D2),
                      size: 34,
                    ),
                    title: Text(
                      'Meus Agendamentos',
                      style: GoogleFonts.chewy(
                        color: Color(0xFF1565C0),
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/client_bookings');
                    },
                  ),
                ],
                ListTile(
                  tileColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  leading: Icon(
                    Icons.account_circle_rounded,
                    color: Color(0xFF1976D2),
                    size: 34,
                  ),
                  title: Text(
                    'Meu Perfil',
                    style: GoogleFonts.chewy(
                      color: Color(0xFF1565C0),
                      fontSize: 22,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, thickness: 1, height: 24),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 16,
                bottom: 32,
                top: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FutureBuilder<DocumentSnapshot>(
                      future:
                          user != null
                              ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get()
                              : Future.value(null),
                      builder: (context, snapshot) {
                        String nome = 'Usuário';
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null &&
                              data['nome'] != null &&
                              (data['nome'] as String).isNotEmpty) {
                            nome = data['nome'];
                          }
                        }
                        return Text(
                          nome,
                          style: GoogleFonts.chewy(
                            color: Color(0xFF1976D2),
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 30),
                    tooltip: 'Sair',
                    onPressed:
                        onLogout ??
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/loginpage',
                            (route) => false,
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
