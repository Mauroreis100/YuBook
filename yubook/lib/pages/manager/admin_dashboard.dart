/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int totalAgendamentos = 0;
  Map<String, int> agendamentoStatus = {
    'pendente': 0,
    'confirmado': 0,
    'concluido': 0,
    'cancelado': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final agendamentosSnapshot =
        await FirebaseFirestore.instance.collection('agendamentos').get();

    totalAgendamentos = agendamentosSnapshot.size;

    for (var doc in agendamentosSnapshot.docs) {
      final status = doc['status']?.toString().toLowerCase();
      if (agendamentoStatus.containsKey(status)) {
        agendamentoStatus[status] = agendamentoStatus[status]! + 1;
      }
    }

    setState(() {});
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.red,
    ];

    final statuses = agendamentoStatus.entries.toList();
    return List.generate(statuses.length, (index) {
      final entry = statuses[index];
      final value = entry.value.toDouble();
      if (value == 0) return PieChartSectionData(showTitle: false, value: 0);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '${entry.key} (${entry.value})',
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Distribuição de Agendamentos por Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Total: $totalAgendamentos agendamentos'),
          ],
        ),
      ),
    );
  }
}
*/