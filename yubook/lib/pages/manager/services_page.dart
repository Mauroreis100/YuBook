import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yubook/services/firebase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BusinessServicesPage extends StatelessWidget {
  final FirebaseServiceAll fireAll = FirebaseServiceAll();

  @override
  Widget build(BuildContext context) {
    final userId = fireAll.getCurrentUserId();
   // final storeName = fireAll.searchDocuments("negocio", 'userId', userId);
    print('User ID: $userId');
    return Scaffold(
      appBar: AppBar(
        title: Text('Serviços'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.event),
            tooltip: 'Agendamentos dos meus serviços',
            onPressed: () {
              Navigator.pushNamed(context, '/manager_dashboard');
            },
          ),
        ],
      ),
      body:
          userId == null
              ? Center(child: Text('Usuário não autenticado'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('servicos')
                        .where('empresaId', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar dados'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(child: Text('Nenhum serviço encontrado'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final serviceId = docs[index].id;
                      return ListTile(
                        title: Text(data['name'] ?? 'Sem nome'),
                        subtitle: Text('R\$ ${data['price'].toString()}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar serviço',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditServicePage(
                                          serviceId: serviceId,
                                          initialData: data,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remover serviço',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Remover serviço'),
                                        content: const Text(
                                          'Tem certeza que deseja remover este serviço?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text(
                                              'Remover',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('servicos')
                                      .doc(serviceId)
                                      .delete();
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Visualizar detalhes, se desejar
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}

class EditServicePage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> initialData;
  const EditServicePage({
    super.key,
    required this.serviceId,
    required this.initialData,
  });

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  List<String> _imageUrls = [];
  List<File> _newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.initialData['description'] ?? '',
    );
    _precoController = TextEditingController(
      text: widget.initialData['price']?.toString() ?? '',
    );
    _imageUrls = (widget.initialData['images'] as List?)?.cast<String>() ?? [];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _imageUrls.length + _newImages.length < 3) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    List<String> finalImages = List.from(_imageUrls);
    final fireAll = FirebaseServiceAll();
    for (var img in _newImages) {
      final url = await fireAll.uploadImage(
        img,
        'servicos/${DateTime.now().millisecondsSinceEpoch}_${img.path.split('/').last}',
      );
      finalImages.add(url);
    }
    await FirebaseFirestore.instance
        .collection('servicos')
        .doc(widget.serviceId)
        .update({
          'name': _nomeController.text,
          'description': _descricaoController.text,
          'price': double.tryParse(_precoController.text) ?? 0.0,
          'images': finalImages,
        });
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Serviço atualizado!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Serviço')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _precoController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Text('Imagens do serviço (máx. 3):'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ..._imageUrls.map(
                          (url) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
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
                        ),
                        ..._newImages.map(
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
                                      _newImages.remove(img);
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
                        ),
                        if (_imageUrls.length + _newImages.length < 3)
                          GestureDetector(
                            onTap: _pickImage,
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
    );
  }
}
