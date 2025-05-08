import 'package:flutter/material.dart';
import 'package:yubook/components/MyTextField.dart';
import 'package:yubook/components/my_button.dart';
class LoginPage extends StatelessWidget{

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void login(){}

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 25,),

              //app name
              Text("Y U B O O K", style: TextStyle(fontSize: 20),),

              const SizedBox(height: 25,),

              //email textfield
              MyTextField(
                  hintText: "Email",
                  controller: emailController,
                  obscureText: false
              ),

              const SizedBox(height: 25,),

              //password textfield
              MyTextField(
                  hintText: "Password",
                  controller: passwordController,
                  obscureText: true
              ),

              const SizedBox(height: 25,),

              // forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Forgot password?", style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                ],
              ),

              const SizedBox(height: 25,),
              // sign in button
              MyButton(
                  text: "Login",
                  onTap: login
              ),

              const SizedBox(height: 25,),

              //don't have an account? Register here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  Text("Register here",
                    style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}