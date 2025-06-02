import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ClientAgendamentosPage extends StatelessWidget {
  const ClientAgendamentosPage({super.key});

  String? getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final userId = getUserId();

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    final agendamentosStream = FirebaseFirestore.instance
        .collection('agendamentos')
        .where('clienteId', isEqualTo: userId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Agendamentos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: agendamentosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

      if (!snapshot.hasData) {
        debugPrint(snapshot.hasData.toString());
  return const Center(child: CircularProgressIndicator());
}

final docs = snapshot.data!.docs;

if (docs.isEmpty) {
  return const Center(child: Text('Nenhum agendamento encontrado.'));
}


          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final servico = data['servico'] ?? {};
              final DateTime? agendadoPara = (data['agendadoPara'] as Timestamp?)?.toDate();
              final status = data['status'] ?? 'pendente';

              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(servico['nome'] ?? 'Serviço'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preço: R\$ ${servico['preco'] ?? '-'}'),
                    if (agendadoPara != null)
                      Text('Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}'),
                    Text('Status: $status'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
