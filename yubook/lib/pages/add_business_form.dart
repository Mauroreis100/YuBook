import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/services/firebase_service.dart';

class AddBusinessFormPage extends StatefulWidget {
  @override
  _AddBusinessFormPageState createState() => _AddBusinessFormPageState();
}

class _AddBusinessFormPageState extends State<AddBusinessFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _closingTimeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _profilePhoto;

final  FirebaseServiceAll fireAll = FirebaseServiceAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Negócio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome do negócio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do negócio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _openingTimeController,
                decoration: InputDecoration(labelText: 'Hora de abertura (opcional)'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _openingTimeController.text = pickedTime.format(context);
                  }
                },
              ),
              TextFormField(
                controller: _closingTimeController,
                decoration: InputDecoration(labelText: 'Hora de encerramento (opcional)'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _closingTimeController.text = pickedTime.format(context);
                  }
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Localização'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  // Logic to pick a profile photo
                  // For now, just simulate picking a photo
                  setState(() {
                    _profilePhoto = 'Foto de perfil selecionada';
                  });
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _profilePhoto == null
                      ? Center(child: Text('Toque para adicionar foto de perfil'))
                      : Center(child: Text('Foto de perfil adicionada')),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Prepare the data to be added to Firestore
                    final businessData = {
                      'name': _nameController.text,
                      'abertura': _openingTimeController.text.isNotEmpty
                          ? _openingTimeController.text
                          : null,
                      'encerramento': _closingTimeController.text.isNotEmpty
                          ? _closingTimeController.text
                          : null,
                      'email': _emailController.text,
                      'phone': _phoneController.text,
                      'location': _locationController.text,
                      'profilePhoto': _profilePhoto ?? 'No photo added',
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    try {
                      // Add data to Firestore
                      await fireAll.addData('negocio', businessData);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Negócio adicionado com sucesso!')),
                      );

                      // Clear the form
                      _formKey.currentState!.reset();
                      setState(() {
                        _profilePhoto = null;
                      });
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "home_page");
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao adicionar negócio: $e')),
                      );
                    }
                  }
                },
                child: const Text('Adicionar Negócio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}