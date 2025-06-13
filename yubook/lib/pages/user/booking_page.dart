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

              return FutureBuilder<DocumentSnapshot>(
                future:
                    negocioId != null
                        ? FirebaseFirestore.instance
                            .collection('negocio')
                            .doc(negocioId)
                            .get()
                        : Future.value(null),
                builder: (context, negocioSnapshot) {
                  final negocioData =
                      negocioSnapshot.data?.data() as Map<String, dynamic>?;
                  final nomeNegocio = negocioData?['name'] ?? 'Negócio';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(servico['nome'] ?? 'Serviço'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Negócio: $nomeNegocio'),
                          if (agendadoPara != null)
                            Text(
                              'Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}',
                            ),
                          Text('Status: $status'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar agendamento',
                            onPressed: () {
                              // TODO: Implementar edição de agendamento
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Funcionalidade de edição em breve!',
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            tooltip: 'Cancelar agendamento',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Cancelar Agendamento'),
                                      content: const Text(
                                        'Tem certeza que deseja cancelar este agendamento?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text('Sim'),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await agendamento.reference.delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Agendamento cancelado!'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
