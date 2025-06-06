import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ServiceListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Services"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('services').snapshots(),
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
              final images = (service['images'] as List?)?.cast<String>() ?? [];
              String? randomImageUrl;
              if (images.isNotEmpty) {
                final random = Random(service.id.hashCode);
                randomImageUrl = images[random.nextInt(images.length)];
              }
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading:
                      randomImageUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(randomImageUrl),
                            radius: 25,
                          )
                          : const CircleAvatar(
                            child: Icon(Icons.design_services, size: 28),
                            radius: 25,
                          ),
                  title: Text(service['name'] ?? 'Unnamed Service'),
                  subtitle: Text(service['description'] ?? 'No description'),
                  onTap: () {
                    // Navegar para detalhes do serviço (a ser implementado)
                    Navigator.pushNamed(
                      context,
                      '/service_details',
                      arguments: {
                        'serviceId': service.id,
                        'negocioId':
                            service['negocioId'] ?? service['businessId'] ?? '',
                      },
                    );
                  },
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available),
                    label: const Text('Agendar'),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/bookingPage',
                        arguments: {
                          'serviceId': service.id,
                          'negocioId':
                              service['negocioId'] ??
                              service['businessId'] ??
                              '',
                        },
                      );
                    },
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
