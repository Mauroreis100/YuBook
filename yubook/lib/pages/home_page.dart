import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/hamburguer.dart';
import 'package:yubook/pages/add_business_form.dart';
import 'package:yubook/pages/loginpage.dart';
import 'package:yubook/pages/registerpage.dart';
import 'package:yubook/pages/user/booking_page.dart';
import 'package:yubook/pages/usertype.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logout(context) {
    FirebaseAuth.instance.signOut();
    // Navigate to the login page
    Navigator.pushNamedAndRemoveUntil(context, '/loginpage', (route) => false);
    
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Home")),
          actions: [IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout)), ],
        ),
        drawer: Drawer(
      backgroundColor: Colors.grey,
      
      child: Column(
        children: [
          DrawerHeader(
            child: Text(
              'YUBOOK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página inicial
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.add, color: Colors.white),
            title: Text('Add Business', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página inicial
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add_business_form');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text('Configurações', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página de configurações
              Navigator.pop(context);
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
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('aDD BUSINESS form', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navegar para a página sobre
                Navigator.pop(context);
                  Navigator.pushNamed(context, '/add_business_form');
              },
            ),
          ),
           Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('loginpage', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Navegar para a página sobre
                Navigator.pop(context);
                  Navigator.pushNamed(context, '/loginpage');
              },
            ),
          ),
        ],
      ),
    ),
      ),
       
      routes: {
        '/home_page': (context) => HomePage(),
        '/loginpage': (context) => LoginPage(onTap: () {}),
      //  '/register': (context) => RegisterPage(onTap: () {}),
        '/usertype': (context) => UserTypePage(),
        '/bookingPage': (context) => BookingPage(),
        '/add_business_form': (context) => AddBusinessFormPage(),
      },
    );
    
  } 
}
