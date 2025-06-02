import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:yubook/services/firebase_service.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetailsPage({super.key, required this.serviceData});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final FirebaseServiceAll fireAll = FirebaseServiceAll();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _criarAgendamento() async {
    final clienteId = fireAll.getCurrentUserId();
    final empresaId = widget.serviceData['empresaId'];

    if (clienteId == null || empresaId == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha data e hora.')),
      );
      return;
    }

    final agendamentoDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await fireAll.addData('agendamentos', {
        'empresaId': empresaId,
        'clienteId': clienteId,
        'createdAt': DateTime.now(),
        'agendadoPara': agendamentoDateTime,
        'status': 'pendente',
        'servico': {
          'nome': widget.serviceData['name'],
          'preco': widget.serviceData['price'],
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento criado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceData = widget.serviceData;
    return Scaffold(
      appBar: AppBar(title: Text(serviceData['name'] ?? 'Detalhes do Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${serviceData['name']}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text("Preço: R\$ ${serviceData['price']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Descrição: ${serviceData['descricao'] ?? 'Sem descrição'}"),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.date_range),
                  label: Text(selectedDate == null
                      ? 'Selecionar data'
                      : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                  onPressed: _pickDate,
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.access_time),
                  label: Text(selectedTime == null
                      ? 'Selecionar hora'
                      : selectedTime!.format(context)),
                  onPressed: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _criarAgendamento,
                child: const Text('Agendar serviço'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
