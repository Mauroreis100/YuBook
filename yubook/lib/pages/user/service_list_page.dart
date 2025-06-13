import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yubook/components/custom_drawer.dart';
import 'package:intl/intl.dart';

class ServiceListPage extends StatelessWidget {
  final String tipoUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ServiceListPage({Key? key, required this.tipoUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isGestor = tipoUser == 'gestor';
    final serviceStream = _firestore.collection('servicos').snapshots();

    dynamic floatingActionButton = null;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: serviceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No services available at the moment."),
            );
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final data = service.data() as Map<String, dynamic>?;
              final images =
                  (data != null &&
                          data.containsKey('images') &&
                          data['images'] is List)
                      ? (data['images'] as List).cast<String>()
                      : <String>[];
              String? randomImageUrl;
              if (images.isNotEmpty) {
                final random = Random(service.id.hashCode);
                randomImageUrl = images[random.nextInt(images.length)];
              }
              // Buscar dados do negócio associado
              final empresaId =
                  data?['empresaId'] ??
                  data?['negocioId'] ??
                  data?['businessId'];
              return FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('negocio')
                        .where('userId', isEqualTo: empresaId)
                        .limit(1)
                        .get(),
                builder: (context, snapshot) {
                  final negocioDocs = snapshot.data?.docs ?? [];
                  final negocioData =
                      negocioDocs.isNotEmpty
                          ? negocioDocs.first.data() as Map<String, dynamic>?
                          : null;
                  final nomeNegocio = negocioData?['name'] ?? 'Negócio';
                  final profilePhoto = negocioData?['profilePhoto'] as String?;
                  final abertura = negocioData?['abertura'] ?? '';
                  final encerramento = negocioData?['encerramento'] ?? '';
                  // Lógica de aberto/fechado
                  bool aberto = false;
                  if (abertura.isNotEmpty && encerramento.isNotEmpty) {
                    try {
                      final now = TimeOfDay.now();
                      final aberturaParts = abertura.split(':');
                      final encerramentoParts = encerramento.split(':');
                      final aberturaTime = TimeOfDay(
                        hour: int.parse(aberturaParts[0]),
                        minute: int.parse(aberturaParts[1]),
                      );
                      final encerramentoTime = TimeOfDay(
                        hour: int.parse(encerramentoParts[0]),
                        minute: int.parse(encerramentoParts[1]),
                      );
                      final nowMinutes = now.hour * 60 + now.minute;
                      final aberturaMinutes =
                          aberturaTime.hour * 60 + aberturaTime.minute;
                      final encerramentoMinutes =
                          encerramentoTime.hour * 60 + encerramentoTime.minute;
                      aberto =
                          nowMinutes >= aberturaMinutes &&
                          nowMinutes < encerramentoMinutes;
                    } catch (_) {}
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/service_details',
                          arguments: {
                            'serviceId': service.id,
                            'negocioId': empresaId,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto de perfil do serviço (imagem aleatória)
                            randomImageUrl != null && randomImageUrl.isNotEmpty
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(randomImageUrl),
                                  radius: 28,
                                )
                                : const CircleAvatar(
                                  child: Icon(Icons.store, size: 28),
                                  radius: 28,
                                ),
                            const SizedBox(width: 12),
                            // Nome do serviço e do negócio
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data?['name'] ?? 'Unnamed Service',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nomeNegocio,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Status aberto/fechado e horários
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  data?['price'] != null
                                      ? 'MZN ${data?['price'].toString().replaceAll('.', ',')}'
                                      : 'Preço não informado',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
