import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    if (clienteId == null ||
        empresaId == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha data e hora.')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceData = widget.serviceData;
    final List<String> images =
        (serviceData['images'] as List?)?.cast<String>() ?? [];
    final String empresaId = serviceData['empresaId'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(serviceData['name'] ?? 'Detalhes do Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('negocio')
                  .doc(empresaId)
                  .get(),
          builder: (context, snapshot) {
            String abertura = '';
            String encerramento = '';
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.exists) {
              final negocioData =
                  snapshot.data!.data() as Map<String, dynamic>?;
              abertura = negocioData?['abertura'] ?? '';
              encerramento = negocioData?['encerramento'] ?? '';
            }
            return ListView(
              children: [
                Text(
                  serviceData['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  serviceData['descricao'] ?? 'Sem descrição',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                if (abertura.isNotEmpty && encerramento.isNotEmpty)
                  Text(
                    'Horário de funcionamento: $abertura - $encerramento',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                const SizedBox(height: 20),
                if (images.isNotEmpty)
                  SizedBox(
                    height: 260,
                    child: PageView.builder(
                      itemCount: images.length,
                      controller: PageController(viewportFraction: 0.85),
                      itemBuilder:
                          (context, idx) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                images[idx],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 260,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stack) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                    ),
                  )
                else
                  Container(
                    height: 260,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.design_services,
                      size: 120,
                      color: Colors.grey[400],
                    ),
                  ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.date_range),
                        label: Text(
                          selectedDate == null
                              ? 'Selecionar data'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        ),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.access_time),
                        label: Text(
                          selectedTime == null
                              ? 'Selecionar hora'
                              : selectedTime!.format(context),
                        ),
                        onPressed: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Preencha data e hora.'),
                          ),
                        );
                        return;
                      }
                      final now = DateTime.now();
                      final agendamentoDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      // Restrição: só pode agendar para pelo menos 2 horas a partir de agora, se for no mesmo dia
                      if (selectedDate!.year == now.year &&
                          selectedDate!.month == now.month &&
                          selectedDate!.day == now.day) {
                        final diff =
                            agendamentoDateTime.difference(now).inMinutes;
                        if (diff < 120) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Agende para pelo menos 2 horas a partir de agora.',
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      await _criarAgendamento();
                    },
                    child: const Text('Agendar serviço'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
