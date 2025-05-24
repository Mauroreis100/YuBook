import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/services/firebase_service.dart';

class BusinessServicesPage extends StatelessWidget {
  final FirebaseServiceAll fireAll = FirebaseServiceAll();

  @override
  Widget build(BuildContext context) {
    final userId = fireAll.getCurrentUserId();
print('User ID: $userId');
    return Scaffold(
      appBar: AppBar(title: Text('Meus Serviços')),
      body: userId == null
          ? Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('servicos')
                  .where('empresaId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar dados'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(child: Text('Nenhum serviço encontrado'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name'] ?? 'Sem nome'),
                      subtitle: Text('R\$ ${data['price'].toString()}'),
                      trailing: Text(data['description'] ?? ''),
                      // Colocar icons de apagar e editar
                    );
                  },
                );
              },
            ),
    );
  }
}
