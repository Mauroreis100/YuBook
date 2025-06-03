import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
