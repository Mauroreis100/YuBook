import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedRole = 'todos';

  Future<void> _updateRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'tipoUser': newRole,
    });
  }

  Future<void> _toggleStatus(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'ativo': !currentStatus,
    });
  }

  Future<void> _deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final stream =
        _selectedRole == 'todos'
            ? _firestore.collection('users').snapshots()
            : _firestore
                .collection('users')
                .where('tipoUser', isEqualTo: _selectedRole)
                .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários', style: Theme.of(context).textTheme.titleLarge),
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
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('Nenhum usuário encontrado.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final nome = data['nome'] ?? 'Sem nome';
              final email = data['email'] ?? 'Sem email';
              final role = data['tipoUser'] ?? 'indefinido';
              final ativo = data['ativo'] ?? true;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      Text('Perfil: $role'),
                      Text('Estado: ${ativo ? 'Ativo' : 'Desativado'}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'toggle') {
                        _toggleStatus(id, ativo);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Remover usuário'),
                                content: const Text(
                                  'Tem certeza que deseja remover este usuário?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteUser(id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Remover'),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        _updateRole(id, value);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'admin',
                            child: Text('Tornar Admin'),
                          ),
                          const PopupMenuItem(
                            value: 'gestor',
                            child: Text('Tornar Gestor'),
                          ),
                          const PopupMenuItem(
                            value: 'cliente',
                            child: Text('Tornar Cliente'),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(ativo ? 'Desativar' : 'Ativar'),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Remover Usuário',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
