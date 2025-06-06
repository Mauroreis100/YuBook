import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ConfirmBookingsPage extends StatelessWidget {
  const ConfirmBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Precisa de estar autenticado.')),
      );
    }
    // Supondo que o gerente só pode ver agendamentos do seu negócio
    // O negocioId pode ser passado via argumentos ou buscado do perfil do usuário
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? negocioId = args != null ? args['negocioId'] : null;
    if (negocioId == null) {
      return const Scaffold(
        body: Center(child: Text('Negócio não encontrado.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos do Negócio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('negocioId', isEqualTo: negocioId)
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
              final estado = agendamento['estado'] ?? 'pendente';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: Text('Cliente: ${agendamento['userId']}'),
                  subtitle: Text(
                    'Serviço: ${agendamento['servicoId']}\nData: '
                    '${dataHora.day}/${dataHora.month}/${dataHora.year} '
                    '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}\n'
                    'Estado: $estado',
                  ),
                  trailing:
                      estado == 'pendente'
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  await agendamentos[index].reference.update({
                                    'estado': 'confirmado',
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await agendamentos[index].reference.update({
                                    'estado': 'rejeitado',
                                  });
                                },
                              ),
                            ],
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManagerAgendamentosPage extends StatefulWidget {
  const ManagerAgendamentosPage({super.key});

  @override
  State<ManagerAgendamentosPage> createState() => _ManagerAgendamentosPageState();
}

class _ManagerAgendamentosPageState extends State<ManagerAgendamentosPage> {
  String? empresaId;

  @override
  void initState() {
    super.initState();
    empresaId = FirebaseAuth.instance.currentUser?.uid;
  }
//Podes usar set
  Future<void> _atualizarStatus(String agendamentoId, String novoStatus) async {
    await FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId)
        .update({'status': novoStatus});
  }

  @override
  Widget build(BuildContext context) {
    if (empresaId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    final agendamentosStream = FirebaseFirestore.instance
        .collection('agendamentos')
        .where('empresaId', isEqualTo: empresaId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos da Empresa')),
      body: StreamBuilder<QuerySnapshot>(
        stream: agendamentosStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum agendamento encontrado.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final agendamento = docs[index];
              final data = agendamento.data() as Map<String, dynamic>;
              final servico = data['servico'] ?? {};
              final status = data['status'] ?? 'pendente';
              final DateTime? agendadoPara = (data['agendadoPara'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(servico['nome'] ?? 'Serviço'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preço: R\$ ${servico['preco'] ?? '-'}'),
                      if (agendadoPara != null)
                        Text('Agendado para: ${DateFormat('dd/MM/yyyy – HH:mm').format(agendadoPara)}'),
                      Text('Status atual: $status'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String novoStatus) {
                      _atualizarStatus(agendamento.id, novoStatus);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'pendente',
                        child: Text('Pendente'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'confirmado',
                        child: Text('Confirmado'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'concluido',
                        child: Text('Concluído'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'cancelado',
                        child: Text('Cancelado'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
