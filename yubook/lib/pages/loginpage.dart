import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yubook/components/MyTextField.dart';
import 'package:yubook/components/my_button.dart';
import 'package:yubook/support/supportFunctions.dart';
class LoginPage extends StatefulWidget{

  final void Function()? onTap;
  const LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

void login() async {
  // Show loading indicator
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
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
       Navigator.pushNamedAndRemoveUntil(context, '/home_page', (route) => false);
       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login successful!')),
                      );
                      
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

  @override
  Widget build(BuildContext context){
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

              const SizedBox(height: 25,),

              //app name
              Text("Y U B O O K", style: TextStyle(fontSize: 20),),

              const SizedBox(height: 25,),

              //email textfKield
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/register');
                      },
                    child: Text("Register here", style: TextStyle(fontWeight: FontWeight.bold),),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}