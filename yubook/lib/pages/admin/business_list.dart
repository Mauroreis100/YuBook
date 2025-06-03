import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmpresaListPage extends StatelessWidget {
  const AdminEmpresaListPage({super.key});

  Future<void> _approveEmpresa(String empresaId) async {
    await FirebaseFirestore.instance.collection('empresas').doc(empresaId).update({
      'status': 'aprovada',
    });
  }

  Future<void> _rejectEmpresa(String empresaId) async {
    await FirebaseFirestore.instance.collection('empresas').doc(empresaId).update({
      'status': 'rejeitada',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empresas Registradas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('empresas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma empresa encontrada.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final empresaId = docs[index].id;
              final nome = data['nome'] ?? 'Sem nome';
              final email = data['email'] ?? 'Sem email';
              final telefone = data['telefone'] ?? 'Sem telefone';
              final status = data['status'] ?? 'pendente';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: $email'),
                      Text('Telefone: $telefone'),
                      Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'aprovar') {
                        _approveEmpresa(empresaId);
                      } else if (value == 'rejeitar') {
                        _rejectEmpresa(empresaId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'aprovar', child: Text('Aprovar')),
                      const PopupMenuItem(value: 'rejeitar', child: Text('Rejeitar')),
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
