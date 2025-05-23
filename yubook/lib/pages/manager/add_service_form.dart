import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yubook/services/firebase_service.dart';
class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

 final FirebaseServiceAll fireAll = FirebaseServiceAll();
  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final String nome = _nomeController.text;
      final String descricao = _descricaoController.text;
      final double preco = double.tryParse(_precoController.text) ?? 0.0;
      

      // TODO: Add logic to save the service (e.g., API call or database operation)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço adicionado com sucesso!')),
      );

      // Clear the form
      _formKey.currentState!.reset();
      _nomeController.clear();
      _descricaoController.clear();
      _precoController.clear();
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Serviço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _precoController,
                decoration: InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
              ),
            
            
              SizedBox(height: 20),
           ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {
      final userId = fireAll.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      final serviceData = {
        'empresaId': userId,
        'name': _nomeController.text,
        'price': double.tryParse(_precoController.text) ?? 0.0,
        'description': _descricaoController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        fireAll.addData('servicos', serviceData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Serviço adicionado com sucesso')),
        );

        Navigator.pop(context);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar serviço: $e')),
        );
      }
    }
  },
  child: Text('Salvar Serviço'),
),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }
}