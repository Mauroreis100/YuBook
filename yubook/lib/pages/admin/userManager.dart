import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yubook/pages/admin/hamburguer_admin.dart';

class UserManagerPage extends StatefulWidget {
  const UserManagerPage({super.key});

  @override
  State<UserManagerPage> createState() => _UserManagerPageState();
}

class _UserManagerPageState extends State<UserManagerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedRole = 'todos';

  Future<void> _updateRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'tipoUser': newRole});
  }

  Future<void> _toggleStatus(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({'ativo': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    final stream = _selectedRole == 'todos'
        ? _firestore.collection('users').snapshots()
        : _firestore
            .collection('users')
            .where('tipoUser', isEqualTo: _selectedRole)
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Utilizadores'),
        actions: [
          DropdownButton<String>(
            value: _selectedRole,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'todos', child: Text('Todos')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'gestor', child: Text('Gestor')),
              DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
            ],
            onChanged: (value) {
              setState(() => _selectedRole = value!);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Nenhum utilizador encontrado.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final nome = data['nome'] ?? 'Sem nome';
              final email = data['email'] ?? 'Sem email';
              final role = data['tipoUser'] ?? 'indefinido';
              final ativo = data['ativo'] ?? true;
              final criado = (data['criadoEm'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      Text('Perfil: $role'),
                      if (criado != null)
                        Text('Criado em: ${DateFormat('dd/MM/yyyy').format(criado)}'),
                      Text('Estado: ${ativo ? 'Ativo' : 'Desativado'}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'toggle') {
                        _toggleStatus(id, ativo);
                      } else {
                        _updateRole(id, value);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'admin', child: const Text('Tornar Admin')),
                      PopupMenuItem(value: 'gestor', child: const Text('Tornar Gestor')),
                      PopupMenuItem(value: 'cliente', child: const Text('Tornar Cliente')),
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'toggle', child: Text(ativo ? 'Desativar' : 'Ativar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      drawer: HamburguerMenuAdmin(),
    );
  }
}
