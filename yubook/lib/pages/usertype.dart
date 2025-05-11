import 'package:flutter/material.dart';

class UserTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha o Tipo de Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Que tipo de usuário você quer ser?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Cliente page or handle Cliente logic
                print('Cliente selected');
              },
              child: Text('Cliente'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to Business page or handle Business logic
                print('Business selected');
              },
              child: Text('Business'),
            ),
          ],
        ),
      ),
    );
  }
}