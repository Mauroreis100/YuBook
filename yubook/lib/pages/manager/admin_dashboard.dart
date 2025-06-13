import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  int total = 0;
  int pendentes = 0;
  int confirmados = 0;
  int concluidos = 0;
  String servicoMaisAgendado = '-';
  List<Map<String, dynamic>> agendamentosPorMes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Buscar o negócio do gerente
    final negocioSnap =
        await FirebaseFirestore.instance
            .collection('negocio')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
    if (negocioSnap.docs.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final negocioId = negocioSnap.docs.first.id;
    // Buscar agendamentos dos serviços deste negócio
    final servicosSnap =
        await FirebaseFirestore.instance
            .collection('servicos')
            .where('empresaId', isEqualTo: negocioId)
            .get();
    final servicoIds = servicosSnap.docs.map((d) => d.id).toList();
    if (servicoIds.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final agendamentosSnap =
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .where('servicoId', whereIn: servicoIds)
            .get();
    total = agendamentosSnap.docs.length;
    pendentes =
        agendamentosSnap.docs.where((d) => d['status'] == 'pendente').length;
    confirmados =
        agendamentosSnap.docs.where((d) => d['status'] == 'confirmado').length;
    concluidos =
        agendamentosSnap.docs.where((d) => d['status'] == 'concluido').length;
    // Serviço mais agendado
    Map<String, int> servicoCount = {};
    for (var doc in agendamentosSnap.docs) {
      final servico = doc['servico'] as Map<String, dynamic>?;
      final nome = servico?['nome'] ?? '-';
      servicoCount[nome] = (servicoCount[nome] ?? 0) + 1;
    }
    if (servicoCount.isNotEmpty) {
      servicoMaisAgendado =
          servicoCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }
    // Evolução dos agendamentos por mês
    Map<String, int> porMes = {};
    for (var doc in agendamentosSnap.docs) {
      final ts = doc['agendadoPara'];
      if (ts is Timestamp) {
        final date = ts.toDate();
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        porMes[key] = (porMes[key] ?? 0) + 1;
      }
    }
    agendamentosPorMes =
        porMes.entries.map((e) => {'month': e.key, 'count': e.value}).toList();
    agendamentosPorMes.sort((a, b) => a['month'].compareTo(b['month']));
    setState(() => _loading = false);
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
                Text(
                  title,
                  style: GoogleFonts.chewy(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value.toString(),
                  style: GoogleFonts.chewy(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Dashboard',
          style: GoogleFonts.chewy(color: Color(0xFF1976D2), fontSize: 28),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1976D2)),
        elevation: 2,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async => _loadDashboard(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildKpiCard(
                      'Total de Agendamentos',
                      total,
                      Icons.event,
                      Color(0xFF1976D2),
                    ),
                    _buildKpiCard(
                      'Pendentes',
                      pendentes,
                      Icons.hourglass_empty,
                      Colors.orange,
                    ),
                    _buildKpiCard(
                      'Confirmados',
                      confirmados,
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildKpiCard(
                      'Concluídos',
                      concluidos,
                      Icons.done_all,
                      Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Serviço mais agendado:',
                      style: GoogleFonts.chewy(
                        fontSize: 18,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    Text(
                      servicoMaisAgendado,
                      style: GoogleFonts.chewy(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Evolução dos Agendamentos',
                      style: GoogleFonts.chewy(
                        fontSize: 18,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child:
                          agendamentosPorMes.isEmpty
                              ? const Center(child: Text('Sem dados'))
                              : LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: [
                                        for (
                                          int i = 0;
                                          i < agendamentosPorMes.length;
                                          i++
                                        )
                                          FlSpot(
                                            i.toDouble(),
                                            agendamentosPorMes[i]['count']
                                                .toDouble(),
                                          ),
                                      ],
                                      isCurved: true,
                                      color: Color(0xFF1976D2),
                                      barWidth: 3,
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          int idx = value.toInt();
                                          if (idx < 0 ||
                                              idx >= agendamentosPorMes.length)
                                            return Container();
                                          return Text(
                                            agendamentosPorMes[idx]['month'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: true),
                                    ),
                                  ),
                                  gridData: FlGridData(show: true),
                                  borderData: FlBorderData(show: true),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
