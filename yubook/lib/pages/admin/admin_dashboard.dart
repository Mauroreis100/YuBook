import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yubook/pages/admin/hamburguer_admin.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  int userCount = 0;
  int serviceCount = 0;
  int bookingCount = 0;
  int businessCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final services = await FirebaseFirestore.instance.collection('servicos').get();
    final bookings = await FirebaseFirestore.instance.collection('agendamentos').get();
    final businesses = await FirebaseFirestore.instance.collection('empresas').get();

    setState(() {
      userCount = users.docs.length;
      serviceCount = services.docs.length;
      bookingCount = bookings.docs.length;
      businessCount = businesses.docs.length;
    });
  }

  Widget _buildKpiCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(value.toString(), style: const TextStyle(fontSize: 20)),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Admin Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKpiCard("Total de Utilizadores", userCount, Icons.person, Colors.blue),
            _buildKpiCard("Serviços Criados", serviceCount, Icons.design_services, Colors.green),
            _buildKpiCard("Agendamentos Feitos", bookingCount, Icons.event, Colors.orange),
            _buildKpiCard("Empresas Registradas", businessCount, Icons.business, Colors.purple),
            const SizedBox(height: 20),
            const Text("Gráficos e Relatórios em breve...",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic))
          ],
        ),
      ),
    drawer: HamburguerMenuAdmin(),
    );
  }
}
