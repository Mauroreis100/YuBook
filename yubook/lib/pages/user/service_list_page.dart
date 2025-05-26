import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading:
                      service['imageUrl'] != null
                          ? Image.network(
                            service['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                          : const Icon(Icons.design_services, size: 50),
                  title: Text(service['name'] ?? 'Unnamed Service'),
                  subtitle: Text(service['description'] ?? 'No description'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/bookingPage',
                      arguments: {
                        'serviceId': service.id,
                        'negocioId':
                            service['negocioId'] ?? service['businessId'] ?? '',
                      },
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
