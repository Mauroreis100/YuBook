import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ServiceBookingsPage extends StatelessWidget {
  final String? serviceId;
  final String serviceName;
  const ServiceBookingsPage({
    Key? key,
    required this.serviceId,
    required this.serviceName,
  }) : super(key: key);

  Future<String> _getUserName(String clienteId) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(clienteId)
            .get();
    final data = userDoc.data();
    if (data != null &&
        data['name'] != null &&
        data['name'].toString().isNotEmpty) {
      return data['name'];
    }
    return 'Cliente';
  }

  @override
  Widget build(BuildContext context) {
    if (serviceId == null) {
      return const Scaffold(
        body: Center(child: Text('Serviço não encontrado.')),
      );
    }
    final bookingsStream =
        FirebaseFirestore.instance
            .collection('agendamentos')
            .where('servicoId', isEqualTo: serviceId)
            .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendamentos do Serviço',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum cliente agendado.'));
          }
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;
              final clienteId = data['clienteId'] ?? '-';
              final servico = data['servico'] ?? {};
              final DateTime? agendadoPara =
                  (data['agendadoPara'] as Timestamp?)?.toDate();
              final status = data['status'] ?? 'pendente';
              return FutureBuilder<String>(
                future: _getUserName(clienteId),
                builder: (context, userSnapshot) {
                  final nomeCliente = userSnapshot.data ?? 'Cliente';
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
                              const Icon(Icons.person, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                'Cliente: $nomeCliente',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Serviço: 	${servico['nome'] ?? '-'}'),
                          if (agendadoPara != null)
                            Text(
                              'Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}',
                            ),
                          Text('Status: $status'),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                final newStatus =
                                    status == 'pendente'
                                        ? 'confirmado'
                                        : 'pendente';
                                await bookings[index].reference.update({
                                  'status': newStatus,
                                });
                              },
                              child: Text(
                                status == 'pendente'
                                    ? 'Confirmar'
                                    : 'Marcar como pendente',
                              ),
                            ),
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
