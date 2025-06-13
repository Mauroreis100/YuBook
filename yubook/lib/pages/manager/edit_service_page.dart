import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/services/firebase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;
  const EditServicePage({Key? key, required this.serviceId}) : super(key: key);

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final FirebaseServiceAll fireAll = FirebaseServiceAll();
  List<String> _imageUrls = [];
  List<File> _selectedImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('servicos')
            .doc(widget.serviceId)
            .get();
    final data = doc.data();
    if (data != null) {
      _nomeController.text = data['name'] ?? '';
      _descricaoController.text = data['description'] ?? '';
      _precoController.text = data['price']?.toString() ?? '';
      _imageUrls = (data['images'] as List?)?.cast<String>() ?? [];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    List<String> imageUrls = List.from(_imageUrls);
    for (var img in _selectedImages) {
      try {
        final userId = fireAll.getCurrentUserId();
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
            content: Text('Erro ao fazer upload da imagem: ${e.toString()}'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }
    }
    final serviceData = {
      'name': _nomeController.text,
      'description': _descricaoController.text,
      'price': double.tryParse(_precoController.text) ?? 0.0,
      'images': imageUrls,
    };
    try {
      await FirebaseFirestore.instance
          .collection('servicos')
          .doc(widget.serviceId)
          .update(serviceData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao atualizar serviço: $e')));
    }
    setState(() => _isLoading = false);
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Serviço',
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
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Por favor, insira o nome'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Por favor, insira a descrição'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Por favor, insira o preço';
                  if (double.tryParse(value) == null)
                    return 'Por favor, insira um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Imagens do serviço (máx. 3):'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._imageUrls.map(
                    (url) => Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipOval(
                          child: Image.network(
                            url,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageUrls.remove(url);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._selectedImages.map(
                    (img) => Stack(
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
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_imageUrls.length + _selectedImages.length < 3)
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
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateService,
                child: const Text('Salvar Alterações'),
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
