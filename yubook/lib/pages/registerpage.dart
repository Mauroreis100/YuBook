import 'package:firebase_auth/firebase_auth.dart';
import 'package:yubook/support/users_firebase.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/MyTextField.dart';
import 'package:yubook/components/my_button.dart';

import '../support/supportFunctions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
final  FirestoreServiceUsers userFirestore = FirestoreServiceUsers();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void registerUser() async {
    // circulo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    // confirmar se as duas passwords sao iguais

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);

      // mostrar mensagpem ao user
      displayMessageToUser("Passwords don't match!", context);
    } else {
      // try to create the user
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

        Navigator.pop(context);
        Navigator.pushNamed(context, '/userType');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        //mostrar a mensagem ao user
        displayMessageToUser(e.code, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

              const SizedBox(height: 25),

              //app name
              Text("Y U B O O K", style: TextStyle(fontSize: 20)),

              const SizedBox(height: 25),

              //username textfKield
              MyTextField(
                hintText: "Username",
                controller: usernameController,
                obscureText: false,
              ),

              const SizedBox(height: 25),

              //email textfKield
              MyTextField(
                hintText: "Email",
                controller: emailController,
                obscureText: false,
              ),

              const SizedBox(height: 25),

              //password textfield
              MyTextField(
                hintText: "Password",
                controller: passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 25),

              //confirm password textfield
              MyTextField(
                hintText: "Confirm Password",
                controller: confirmPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 25),

              const SizedBox(height: 25),
              // sign in button
              MyButton(text: "Register", onTap: registerUser),

              const SizedBox(height: 25),

              //Already have an account? Login here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
