import 'package:flutter/material.dart';

class HamburguerMenu extends StatelessWidget {
  const HamburguerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            title: Text('Adicionar Serviço', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página de configurações
              Navigator.pop(context);
               Navigator.pushNamed(context, '/services_page');
            },
          ),
           ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text('Ver Serviços', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página de configurações
              Navigator.pop(context,  '/services_view');
            },
          ),
 ListTile(
            leading: Icon(Icons.settings, color: Colors.white),
            title: Text('Ver Serviços', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navegar para a página de configurações
              Navigator.pop(context,  '/services_page');
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
    );
  }
}
