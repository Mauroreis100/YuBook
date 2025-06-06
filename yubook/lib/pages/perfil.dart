import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController? _nomeController;
  TextEditingController? _emailController;
  String? _tipoUser;
  String? _negocioImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    String? negocioImageUrl;
    if (data['tipoUser'] == 'gestor') {
      final negocioSnap =
          await _firestore
              .collection('negocio')
              .where('userId', isEqualTo: user.uid)
              .limit(1)
              .get();
      if (negocioSnap.docs.isNotEmpty) {
        negocioImageUrl = negocioSnap.docs.first['profilePhoto'] as String?;
      }
    }
    setState(() {
      _nomeController = TextEditingController(text: data['nome'] ?? '');
      _emailController = TextEditingController(text: data['email'] ?? '');
      _tipoUser = data['tipoUser'] ?? '';
      _negocioImageUrl = negocioImageUrl;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'nome': _nomeController?.text ?? '',
      // Email geralmente não é editável, mas pode ser adicionado aqui se necessário
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/loginpage', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_tipoUser == 'gestor' &&
                _negocioImageUrl != null &&
                _negocioImageUrl!.isNotEmpty)
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(_negocioImageUrl!),
                ),
              ),
            if (_tipoUser == 'gestor') const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false, // Email não editável
            ),
            const SizedBox(height: 16),
            Text('Tipo de usuário: ${_tipoUser ?? ''}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
