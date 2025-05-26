import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

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
        title: const Text('Agendamentos dos Meus Serviços'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('services')
                .where('negocioId', isEqualTo: user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }
          final services = snapshot.data!.docs;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index].data() as Map<String, dynamic>;
              final serviceId = services[index].id;
              return ExpansionTile(
                title: Text(service['name'] ?? 'Serviço'),
                subtitle: Text(service['description'] ?? ''),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('agendamentos')
                            .where('servicoId', isEqualTo: serviceId)
                            .orderBy('dataHora', descending: false)
                            .snapshots(),
                    builder: (context, agendamentoSnapshot) {
                      if (agendamentoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!agendamentoSnapshot.hasData ||
                          agendamentoSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Nenhum agendamento para este serviço.'),
                        );
                      }
                      final agendamentos = agendamentoSnapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: agendamentos.length,
                        itemBuilder: (context, idx) {
                          final agendamento =
                              agendamentos[idx].data() as Map<String, dynamic>;
                          final dataHora =
                              (agendamento['dataHora'] as Timestamp).toDate();
                          return ListTile(
                            leading: const Icon(Icons.event_available),
                            title: Text('Cliente: \\${agendamento['userId']}'),
                            subtitle: Text(
                              'Data: \\${dataHora.day}/\\${dataHora.month}/\\${dataHora.year} \\${dataHora.hour.toString().padLeft(2, '0')}:\\${dataHora.minute.toString().padLeft(2, '0')}\nEstado: \\${agendamento['estado']}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
