import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmpresaListPage extends StatelessWidget {
  const AdminEmpresaListPage({super.key});

  Future<void> _removeNegocio(String negocioId) async {
    await FirebaseFirestore.instance
        .collection('negocio')
        .doc(negocioId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Negócios Cadastrados')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('negocio').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum negócio encontrado.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final negocioId = docs[index].id;
              final nome = data['name'] ?? 'Sem nome';
              final email = data['email'] ?? 'Sem email';
              final telefone = data['phone'] ?? 'Sem telefone';
              final status = data['status'] ?? 'ativo';
              final profilePhoto = data['profilePhoto'] as String?;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading:
                      profilePhoto != null && profilePhoto.isNotEmpty
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(profilePhoto),
                          )
                          : const CircleAvatar(child: Icon(Icons.store)),
                  title: Text(nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: $email'),
                      Text('Telefone: $telefone'),
                      Text(
                        'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remover negócio',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Remover negócio'),
                              content: const Text(
                                'Tem certeza que deseja remover este negócio?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Remover',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await _removeNegocio(negocioId);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AdminServicosDoNegocioPage(
                              negocioId: negocioId,
                              nomeNegocio: nome,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminServicosDoNegocioPage extends StatelessWidget {
  final String negocioId;
  final String nomeNegocio;
  const AdminServicosDoNegocioPage({
    super.key,
    required this.negocioId,
    required this.nomeNegocio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serviços de $nomeNegocio')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('servicos')
                .where('empresaId', isEqualTo: negocioId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final nome = data['name'] ?? 'Sem nome';
              final preco = data['price']?.toString() ?? '-';
              final descricao = data['description'] ?? '';
              return ListTile(
                leading: const Icon(Icons.design_services),
                title: Text(nome),
                subtitle: Text('Preço: R\$ $preco\n$descricao'),
              );
            },
          );
        },
      ),
    );
  }
}
