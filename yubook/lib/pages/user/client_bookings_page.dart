import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ClientBookingsPage extends StatelessWidget {
  const ClientBookingsPage({super.key});

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

    final agendamentosStream =
        FirebaseFirestore.instance
            .collection('agendamentos')
            .where('clienteId', isEqualTo: userId)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Agendamentos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: agendamentosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final agendamento = docs[index];
              final data = agendamento.data() as Map<String, dynamic>;
              final servico = data['servico'] ?? {};
              final String? servicoId = data['servicoId'];
              final String? negocioId =
                  data['negocioId'] ?? data['empresaId'] ?? data['businessId'];
              final DateTime? agendadoPara =
                  (data['agendadoPara'] as Timestamp?)?.toDate();
              final status = data['status'] ?? 'pendente';

              if (negocioId == null) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_note, size: 32),
                            const SizedBox(width: 8),
                            Text(
                              servico['nome'] ?? 'Serviço',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Negócio: Negócio'),
                        if (agendadoPara != null)
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}',
                          ),
                        Text('Status: $status'),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('negocio')
                          .doc(negocioId)
                          .get(),
                  builder: (context, negocioSnapshot) {
                    String nomeNegocio = 'Negócio';
                    if (negocioSnapshot.hasData &&
                        negocioSnapshot.data != null) {
                      final raw = negocioSnapshot.data!.data();
                      if (raw != null &&
                          raw is Map<String, dynamic> &&
                          raw['name'] != null) {
                        nomeNegocio = raw['name'];
                      }
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event_note, size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  servico['nome'] ?? 'Serviço',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Negócio: $nomeNegocio'),
                            if (agendadoPara != null)
                              Text(
                                'Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}',
                              ),
                            Text('Status: $status'),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
