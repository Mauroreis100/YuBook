import 'package:flutter/material.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _servicoIdController = TextEditingController();
  final TextEditingController _empresaIdController = TextEditingController();

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final String nome = _nomeController.text;
      final String descricao = _descricaoController.text;
      final double preco = double.tryParse(_precoController.text) ?? 0.0;
      final String servicoId = _servicoIdController.text;
      final String empresaId = _empresaIdController.text;

      // TODO: Add logic to save the service (e.g., API call or database operation)

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço adicionado com sucesso!')),
      );

      // Clear the form
      _formKey.currentState!.reset();
      _nomeController.clear();
      _descricaoController.clear();
      _precoController.clear();
      _servicoIdController.clear();
      _empresaIdController.clear();
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
              TextFormField(
                controller: _servicoIdController,
                decoration: InputDecoration(labelText: 'Serviço ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ID do serviço';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _empresaIdController,
                decoration: InputDecoration(labelText: 'Empresa ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ID da empresa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveService,
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
    _servicoIdController.dispose();
    _empresaIdController.dispose();
    super.dispose();
  }
}