import 'package:firebase_auth/firebase_auth.dart';
import 'package:yubook/support/users_firebase.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/MyTextField.dart';
import 'package:yubook/components/my_button.dart';
import 'package:yubook/services/firebase_service.dart';

import '../support/supportFunctions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirestoreServiceUsers userFirestore = FirestoreServiceUsers();
  final FirebaseServiceAll firebaseService = FirebaseServiceAll();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  void registerUser() async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Confirm if the two passwords match
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);

      // Show message to the user
      displayMessageToUser("Passwords don't match!", context);
    } else {
      // Try to create the user
      try {
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

        // Save user data to Firestore
        await userFirestore.createUserDocument(
          userCredential.user!.uid,
          usernameController.text,
          emailController.text,
          null,
        );
        print(userCredential.user!.uid);

        // Navigate to the usertype page and pass the data
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/usertype',
            arguments: {
              'username': usernameController.text,
              'email': emailController.text,
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        // Show the error message to the user
        displayMessageToUser(e.code, context);
      }
    }
  }

  void loginWithGoogle() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final user = await firebaseService.signInWithGoogle();
      if (user == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      // Verifica se o user já existe no Firestore
      final snapshot = await userFirestore.users.doc(user.uid).get();
      if (!snapshot.exists) {
        // Novo utilizador, criar documento e ir para escolha de tipo
        await userFirestore.createUserDocument(
          user.uid,
          user.displayName ?? '',
          user.email ?? '',
          null,
        );
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/usertype',
            arguments: {
              'username': user.displayName ?? '',
              'email': user.email ?? '',
              'uid': user.uid,
            },
          );
        }
      } else {
        // Já existe, vai para home
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_page',
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      displayMessageToUser('Erro ao fazer login com Google', context);
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

              const SizedBox(height: 16),

              MyGoogleButton(text: "Entrar com Google", onTap: loginWithGoogle),

              const SizedBox(height: 25),

              //Already have an account? Login here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/loginpage');
                    },
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
