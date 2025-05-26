import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Precisa de estar autenticado.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('userId', isEqualTo: user.uid)
                .orderBy('dataHora', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado.'));
          }
          final agendamentos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento =
                  agendamentos[index].data() as Map<String, dynamic>;
              final dataHora = (agendamento['dataHora'] as Timestamp).toDate();
              return ListTile(
                leading: const Icon(Icons.event_available),
                title: Text('Serviço: ${agendamento['servicoId']}'),
                subtitle: Text(
                  'Data: ${dataHora.day}/${dataHora.month}/${dataHora.year} ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}\nEstado: ${agendamento['estado']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
