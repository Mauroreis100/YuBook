import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yubook/pages/admin/hamburguer_admin.dart';
import 'package:yubook/components/custom_drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  int userCount = 0;
  int serviceCount = 0;
  int bookingCount = 0;
  int businessCount = 0;

  // Adicione variáveis para os dados dos gráficos
  Map<String, int> bookingStatusCount = {};
  List<Map<String, dynamic>> bookingsPerMonth = [];
  List<Map<String, dynamic>> businessesPerMonth = [];
  List<Map<String, dynamic>> usersPerMonth = [];
  List<Map<String, dynamic>> topServices = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _loadCharts();
  }

  Future<void> _loadMetrics() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final services =
        await FirebaseFirestore.instance.collection('servicos').get();
    final bookings =
        await FirebaseFirestore.instance.collection('agendamentos').get();
    final businesses =
        await FirebaseFirestore.instance.collection('negocio').get();

    setState(() {
      userCount = users.docs.length;
      serviceCount = services.docs.length;
      bookingCount = bookings.docs.length;
      businessCount = businesses.docs.length;
    });
  }

  Future<void> _loadCharts() async {
    // 1. Distribuição de agendamentos por status
    final bookings =
        await FirebaseFirestore.instance.collection('agendamentos').get();
    bookingStatusCount = {};
    for (var doc in bookings.docs) {
      final status = doc['status']?.toString() ?? 'pendente';
      bookingStatusCount[status] = (bookingStatusCount[status] ?? 0) + 1;
    }

    // 2. Evolução de agendamentos ao longo do tempo (por mês)
    Map<String, int> bookingsByMonth = {};
    for (var doc in bookings.docs) {
      final ts = doc['agendadoPara'];
      if (ts is Timestamp) {
        final date = ts.toDate();
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        bookingsByMonth[key] = (bookingsByMonth[key] ?? 0) + 1;
      }
    }
    bookingsPerMonth =
        bookingsByMonth.entries
            .map((e) => {'month': e.key, 'count': e.value})
            .toList();
    bookingsPerMonth.sort((a, b) => a['month'].compareTo(b['month']));

    // 3. Novos negócios por mês
    final businesses =
        await FirebaseFirestore.instance.collection('negocio').get();
    Map<String, int> businessesByMonth = {};
    for (var doc in businesses.docs) {
      final ts = doc['createdAt'] ?? doc['criadoEm'];
      if (ts is Timestamp) {
        final date = ts.toDate();
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        businessesByMonth[key] = (businessesByMonth[key] ?? 0) + 1;
      }
    }
    businessesPerMonth =
        businessesByMonth.entries
            .map((e) => {'month': e.key, 'count': e.value})
            .toList();
    businessesPerMonth.sort((a, b) => a['month'].compareTo(b['month']));

    // 4. Novos usuários por mês
    final users = await FirebaseFirestore.instance.collection('users').get();
    Map<String, int> usersByMonth = {};
    for (var doc in users.docs) {
      final ts = doc['criadoEm'] ?? doc['createdAt'];
      if (ts is Timestamp) {
        final date = ts.toDate();
        final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
        usersByMonth[key] = (usersByMonth[key] ?? 0) + 1;
      }
    }
    usersPerMonth =
        usersByMonth.entries
            .map((e) => {'month': e.key, 'count': e.value})
            .toList();
    usersPerMonth.sort((a, b) => a['month'].compareTo(b['month']));

    // 5. Top serviços mais agendados
    Map<String, int> serviceCountMap = {};
    for (var doc in bookings.docs) {
      final service = doc['servico'] as Map<String, dynamic>?;
      final name = service?['nome'] ?? 'Desconhecido';
      serviceCountMap[name] = (serviceCountMap[name] ?? 0) + 1;
    }
    topServices =
        serviceCountMap.entries
            .map((e) => {'name': e.key, 'count': e.value})
            .toList();
    topServices.sort((a, b) => b['count'].compareTo(a['count']));
    if (topServices.length > 5) topServices = topServices.sublist(0, 5);

    setState(() {});
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(value.toString(), style: const TextStyle(fontSize: 20)),
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
        title: Text(
          'Super Admin Dashboard',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadMetrics();
          await _loadCharts();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKpiCard(
              "Total de Utilizadores",
              userCount,
              Icons.person,
              Colors.blue,
            ),
            _buildKpiCard(
              "Serviços Criados",
              serviceCount,
              Icons.design_services,
              Colors.green,
            ),
            _buildKpiCard(
              "Agendamentos Feitos",
              bookingCount,
              Icons.event,
              Colors.orange,
            ),
            _buildKpiCard(
              "Empresas Registradas",
              businessCount,
              Icons.business,
              Colors.purple,
            ),
            const SizedBox(height: 20),
            Text(
              "Distribuição de Agendamentos por Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      bookingStatusCount.entries.map((e) {
                        final color =
                            e.key == 'pendente'
                                ? Colors.orange
                                : e.key == 'confirmado'
                                ? Colors.green
                                : e.key == 'concluido'
                                ? Colors.blue
                                : Colors.red;
                        return PieChartSectionData(
                          color: color,
                          value: e.value.toDouble(),
                          title: "${e.key} (${e.value})",
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Evolução de Agendamentos por Mês",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < bookingsPerMonth.length; i++)
                          FlSpot(
                            i.toDouble(),
                            bookingsPerMonth[i]['count'].toDouble(),
                          ),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= bookingsPerMonth.length)
                            return Container();
                          return Text(
                            bookingsPerMonth[idx]['month'],
                            style: const TextStyle(fontSize: 10),
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
            const SizedBox(height: 20),
            Text(
              "Novos Negócios por Mês",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < businessesPerMonth.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: businessesPerMonth[i]['count'].toDouble(),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= businessesPerMonth.length)
                            return Container();
                          return Text(
                            businessesPerMonth[idx]['month'],
                            style: const TextStyle(fontSize: 10),
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
            const SizedBox(height: 20),
            Text(
              "Novos Usuários por Mês",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < usersPerMonth.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: usersPerMonth[i]['count'].toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= usersPerMonth.length)
                            return Container();
                          return Text(
                            usersPerMonth[idx]['month'],
                            style: const TextStyle(fontSize: 10),
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
            const SizedBox(height: 20),
            Text(
              "Top Serviços Mais Agendados",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < topServices.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: topServices[i]['count'].toDouble(),
                            color: Colors.green,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= topServices.length)
                            return Container();
                          return Text(
                            topServices[idx]['name'],
                            style: const TextStyle(fontSize: 10),
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
      drawer: CustomDrawer(tipoUser: 'admin'),
    );
  }
}
