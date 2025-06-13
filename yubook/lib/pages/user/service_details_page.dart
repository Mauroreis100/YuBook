import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ServiceDetailsPage extends StatefulWidget {
  const ServiceDetailsPage({super.key});

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _agendarServico(
    Map<String, dynamic> service,
    String? serviceId, {
    DateTime? agendamentoDateTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
      return;
    }
    if (agendamentoDateTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione data e hora.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('agendamentos').add({
        'clienteId': user.uid,
        'servicoId': serviceId,
        'agendadoPara': agendamentoDateTime,
        'servico': {'nome': service['name'], 'preco': service['price']},
        'status': 'pendente',
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento criado com sucesso!')),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao agendar: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? serviceId = args != null ? args['serviceId'] : null;

    if (serviceId == null) {
      return const Scaffold(
        body: Center(child: Text('Serviço não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Serviço'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('servicos')
                .doc(serviceId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Serviço não encontrado.'));
          }
          final service = snapshot.data!.data() as Map<String, dynamic>;
          final images =
              (service.containsKey('images') && service['images'] is List)
                  ? (service['images'] as List).cast<String>()
                  : <String>[];
          final empresaId =
              service['empresaId'] ??
              service['negocioId'] ??
              service['businessId'];
          return FutureBuilder<DocumentSnapshot>(
            future:
                empresaId != null
                    ? FirebaseFirestore.instance
                        .collection('negocio')
                        .doc(empresaId)
                        .get()
                    : Future.value(null),
            builder: (context, negocioSnapshot) {
              String abertura = '';
              String encerramento = '';
              if (negocioSnapshot.hasData &&
                  negocioSnapshot.data != null &&
                  negocioSnapshot.data!.exists) {
                final negocioData =
                    negocioSnapshot.data!.data() as Map<String, dynamic>?;
                abertura = negocioData?['abertura'] ?? '';
                encerramento = negocioData?['encerramento'] ?? '';
              }
              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Text(
                    service['name'] ?? 'Serviço',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service['description'] ?? 'Sem descrição',
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Data',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDate == null
                                ? '--/--/----'
                                : DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Hora',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime == null
                                ? '--:--'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _selectedTime == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _selectedDate == null
                                ? 'Selecionar data'
                                : DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedDate!),
                          ),
                          onPressed: () => _pickDate(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            _selectedTime == null
                                ? 'Selecionar hora'
                                : _selectedTime!.format(context),
                          ),
                          onPressed: () => _pickTime(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.event_available),
                      label: const Text('Agendar este serviço'),
                      onPressed:
                          (_selectedDate != null &&
                                  _selectedTime != null &&
                                  !_isLoading)
                              ? () async {
                                final now = DateTime.now();
                                final agendamentoDateTime = DateTime(
                                  _selectedDate!.year,
                                  _selectedDate!.month,
                                  _selectedDate!.day,
                                  _selectedTime!.hour,
                                  _selectedTime!.minute,
                                );
                                if (_selectedDate!.year == now.year &&
                                    _selectedDate!.month == now.month &&
                                    _selectedDate!.day == now.day) {
                                  final diff =
                                      agendamentoDateTime
                                          .difference(now)
                                          .inMinutes;
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
                                await _agendarServico(
                                  service,
                                  serviceId,
                                  agendamentoDateTime: agendamentoDateTime,
                                );
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                }
                              }
                              : null,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
