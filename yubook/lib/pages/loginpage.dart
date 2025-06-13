import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/MyTextField.dart';
import 'package:yubook/components/my_button.dart';
import 'package:yubook/support/supportFunctions.dart';
import 'package:yubook/services/firebase_service.dart';
import 'package:yubook/support/users_firebase.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final FirebaseServiceAll firebaseService = FirebaseServiceAll();
  final FirestoreServiceUsers userFirestore = FirestoreServiceUsers();

  void login() async {
    // Show loading indicator
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Attempt to sign in
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Check if the widget is still mounted before popping the loading dialog
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home_page',
          (route) => false,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
      }
    } on FirebaseAuthException catch (e) {
      // Check if the widget is still mounted before handling the error
      if (mounted) {
        Navigator.pop(context);

        displayMessageToUser(e.code, context);
      }
    } catch (e) {
      // Handle any other exceptions
      if (mounted) {
        Navigator.pop(context);
        displayMessageToUser("An unexpected error occurred.", context);
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Image.asset('assets/icon2.png', height: 100),

                const SizedBox(height: 25),

                //app name
                Text(
                  "Y U B O O K",
                  style: Theme.of(context).textTheme.titleLarge,
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

                // forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot password?",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                // sign in button
                MyButton(text: "Login", onTap: login),

                const SizedBox(height: 16),

                MyGoogleButton(
                  text: "Entrar com Google",
                  onTap: loginWithGoogle,
                ),

                const SizedBox(height: 25),

                //don't have an account? Register here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "Register here",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
