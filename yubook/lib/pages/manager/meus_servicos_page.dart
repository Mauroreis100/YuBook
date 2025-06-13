import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MeusServicosPage extends StatelessWidget {
  const MeusServicosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }
    final serviceStream =
        FirebaseFirestore.instance
            .collection('servicos')
            .where('empresaId', isEqualTo: userId)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meus Serviços',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: serviceStream,
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
              final service = services[index];
              final data = service.data() as Map<String, dynamic>?;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.design_services, size: 28),
                  title: Text(service['name'] ?? 'Unnamed Service'),
                  subtitle: Text(service['description'] ?? 'No description'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/service_bookings',
                      arguments: {
                        'serviceId': service.id,
                        'serviceName': service['name'] ?? 'Serviço',
                      },
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit_service_form',
                            arguments: {'serviceId': service.id},
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Excluir Serviço'),
                                  content: const Text(
                                    'Tem certeza que deseja excluir este serviço?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            // Buscar as imagens do serviço antes de deletar
                            final serviceDoc =
                                await FirebaseFirestore.instance
                                    .collection('servicos')
                                    .doc(service.id)
                                    .get();
                            final data = serviceDoc.data();
                            if (data != null &&
                                data['images'] != null &&
                                data['images'] is List) {
                              for (String url
                                  in (data['images'] as List).cast<String>()) {
                                try {
                                  final ref = FirebaseStorage.instance
                                      .refFromURL(url);
                                  await ref.delete();
                                } catch (e) {
                                  print(
                                    'Erro ao deletar imagem do Storage: $e',
                                  );
                                }
                              }
                            }
                            // Deletar todos os agendamentos relacionados a este serviço
                            final agendamentos =
                                await FirebaseFirestore.instance
                                    .collection('agendamentos')
                                    .where('servicoId', isEqualTo: service.id)
                                    .get();
                            for (final doc in agendamentos.docs) {
                              await doc.reference.delete();
                            }
                            // Agora deleta o documento do serviço
                            await FirebaseFirestore.instance
                                .collection('servicos')
                                .doc(service.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Serviço e agendamentos excluídos com sucesso!',
                                ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_service_form');
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Serviço',
      ),
    );
  }
}
