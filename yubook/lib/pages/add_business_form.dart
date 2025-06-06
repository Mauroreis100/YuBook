import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/services/firebase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  File? _selectedImage;

  final FirebaseServiceAll fireAll = FirebaseServiceAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Negócio')),
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
                decoration: InputDecoration(
                  labelText: 'Hora de abertura (opcional)',
                ),
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
                decoration: InputDecoration(
                  labelText: 'Hora de encerramento (opcional)',
                ),
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
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child:
                      _selectedImage == null
                          ? Center(
                            child: Text('Toque para adicionar foto de perfil'),
                          )
                          : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String? imageUrl;
                    if (_selectedImage != null) {
                      imageUrl = await fireAll.uploadImage(
                        _selectedImage!,
                        'negocios/${DateTime.now().millisecondsSinceEpoch}.jpg',
                      );
                    }
                    final businessData = {
                      'userId': fireAll.getCurrentUserId(),
                      'name': _nameController.text,
                      'abertura':
                          _openingTimeController.text.isNotEmpty
                              ? _openingTimeController.text
                              : null,
                      'encerramento':
                          _closingTimeController.text.isNotEmpty
                              ? _closingTimeController.text
                              : null,
                      'email': _emailController.text,
                      'phone': _phoneController.text,
                      'location': _locationController.text,
                      'profilePhoto': imageUrl ?? '',
                      'createdAt': FieldValue.serverTimestamp(),
                    };
                    try {
                      await fireAll.addData('negocio', businessData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Negócio adicionado com sucesso!'),
                        ),
                      );
                      _formKey.currentState!.reset();
                      setState(() {
                        _selectedImage = null;
                      });
                      NavigatorState? navigatorState = Navigator.maybeOf(
                        context,
                      );
                      if (navigatorState != null) {
                        navigatorState
                          ..pop()
                          ..pop()
                          ..pushNamed('/home_page');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar negócio: $e'),
                        ),
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
