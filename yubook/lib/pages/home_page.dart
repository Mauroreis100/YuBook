import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yubook/pages/service_detail.dart';
import 'package:yubook/services/firebase_service.dart';
import 'service_detail.dart';

class HomePage extends StatelessWidget {
  final FirebaseServiceAll fireAll = FirebaseServiceAll();

  HomePage({super.key});

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/loginpage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = fireAll.getCurrentUserId();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Home")),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.event),
              tooltip: 'Meus Agendamentos',
              onPressed: () {
                Navigator.pushNamed(context, '/booking_history');
              },
            ),
            IconButton(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: userId == null
            ? const Center(child: Text('Usuário não autenticado'))
            : FutureBuilder<DocumentSnapshot>(
                future: fireAll.getDocument("users", userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Usuário não encontrado'));
                  }
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
debugPrint(userData['tipoUser'].toString());
                  final tipoUser = userData['tipoUser'].toString();

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('servicos')
                        .snapshots(),
                    builder: (context, servicosSnapshot) {
                      if (servicosSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (servicosSnapshot.hasError) {
                        return const Center(child: Text('Erro ao carregar dados'));
                      }

                      final docs = servicosSnapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('Nenhum serviço encontrado'));
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;

                          return ListTile(
                            title: Text(data['name'] ?? 'Sem nome'),
                            subtitle: Text('R\$ ${data['price'].toString()}'),
                            trailing: const Text('Ver mais'),
                            onTap: () {
                              if (tipoUser == 'gestor' || tipoUser == 'Cliente') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceDetailsPage(serviceData: data),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Apenas Admins ou Managers podem ver detalhes'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
        drawer: Drawer(
          backgroundColor: Colors.grey,
          child: Column(
            children: [
              const DrawerHeader(
                child: Text(
                  'YUBOOK',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/home_page');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Add Business',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add_business_form');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Adicionar Serviço',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/add_service_form');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Ver Serviço',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/services_page');
                },
              ),
               ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Ver Agendamentos',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/booking_page');
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title:
                      const Text('Sobre', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
