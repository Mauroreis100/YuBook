import 'package:flutter/material.dart';

class HamburguerMenuAdmin extends StatelessWidget {
  const HamburguerMenuAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey,

      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              'YUBOOK',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página inicial
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin_dashboard');
            },
          ),
          ListTile(
            leading: Icon(Icons.add, color: Colors.white),
            title: Text('User Manager', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página inicial
              Navigator.pop(context);
              Navigator.pushNamed(context, '/userManager');
            },
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('Sobre', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navegar para a página sobre
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('Register', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navegar para a página sobre
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
            ),
          ),
        ],
      ),
    );
  }
}
