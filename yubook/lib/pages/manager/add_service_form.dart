import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yubook/services/firebase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
  List<File> _selectedImages = [];

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

  Future<bool> checarPermissaoGaleria() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) return true;
    // Para Androids antigos, tente storage
    status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar Serviço',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
              SizedBox(height: 16),
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
              SizedBox(height: 16),
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
              // Campo para selecionar até 3 imagens
              SizedBox(height: 16),
              Text('Imagens do serviço (máx. 3):'),
              SizedBox(height: 8),
              Row(
                children: [
                  ..._selectedImages.map(
                    (img) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipOval(
                            child: Image.file(
                              img,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.remove(img);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedImages.length < 3)
                    GestureDetector(
                      onTap: () async {
                        if (await checarPermissaoGaleria()) {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setState(() {
                              _selectedImages.add(File(pickedFile.path));
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Permissão para acessar fotos/arquivos negada.',
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_a_photo, color: Colors.grey[700]),
                      ),
                    ),
                ],
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

                    // Upload das imagens
                    List<String> imageUrls = [];
                    for (var img in _selectedImages) {
                      try {
                        print('Preparando upload:');
                        print('  Path local: ${img.path}');
                        print('  Arquivo existe? ${img.existsSync()}');
                        print('  UID do usuário: ${userId}');
                        final storagePath =
                            'servicos/$userId/${DateTime.now().millisecondsSinceEpoch}_${img.path.split('/').last}';
                        print('  Path no Storage: $storagePath');
                        final url = await fireAll.uploadImage(img, storagePath);
                        imageUrls.add(url);
                        print('Upload concluído. URL: $url');
                      } catch (e, stack) {
                        print('Erro ao fazer upload: ${e.toString()}');
                        print(stack);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao fazer upload da imagem: ${e.toString()}',
                            ),
                          ),
                        );
                        return;
                      }
                    }

                    final serviceData = {
                      'empresaId': userId,
                      'name': _nomeController.text,
                      'price': double.tryParse(_precoController.text) ?? 0.0,
                      'description': _descricaoController.text,
                      'images': imageUrls,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    try {
                      fireAll.addData('servicos', serviceData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Serviço adicionado com sucesso'),
                        ),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao adicionar serviço: $e'),
                        ),
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
