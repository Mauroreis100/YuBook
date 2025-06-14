import 'package:flutter/material.dart';
import 'package:yubook/pages/registerpage.dart';
import 'package:yubook/pages/loginpage.dart';


//Este é a pior lógica de aplicativo que já mexi! 

class LoginOrRegister extends StatefulWidget{

  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister>{

  //mostrar pagina de login ao abrir o app
  bool showLoginPage = true;

  //mudar entre pagina de login e register

  void togglePages(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context){
    if(showLoginPage){
      return LoginPage(onTap: togglePages);
    }else{
      return RegisterPage(onTap: togglePages);
    }
  }



}