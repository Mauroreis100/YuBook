import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{

  HomePage({super.key});

  void logout(){
    FirebaseAuth.instance.signOut();
  }

  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text("Home"),),actions: [
          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],),
      ),
    );
  }

}