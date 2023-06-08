import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logmap/services/auth.dart';
import 'package:logmap/shared/custom_textfield.dart';
import 'package:logmap/shared/icons.dart';


class EmailPasswordSignUp extends StatefulWidget {
  const EmailPasswordSignUp({super.key});

  @override
  State<EmailPasswordSignUp> createState() => _EmailPasswordSignUpState();
}

class _EmailPasswordSignUpState extends State<EmailPasswordSignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signUpUser() async {
    FirebaseAuthMethods(FirebaseAuth.instance).signUpWithEmail(
      email: emailController.text, 
      password: passwordController.text, 
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Logmap',
            style: TextStyle(fontSize: 50),
          ),
          Image.asset(logMapLogo),
          const Text(
            'Cadastro',
            style: TextStyle(fontSize: 35),
          ), 
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: emailController,
              hintText: 'Email',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: passwordController,
              hintText: 'Senha'),
          ),
          const SizedBox(height: 20),
          LoginButton(
            text: 'Cadastre-se', 
            icon: Icons.accessibility_new, 
            color: Colors.greenAccent.shade700, 
            loginMethod: signUpUser,
            height: 10,
            width: 20,
          ),
        ],
      ),
    );
  }
}

class EmailPasswordLogin extends StatefulWidget {
  const EmailPasswordLogin({super.key});

  @override
  State<EmailPasswordLogin> createState() => _EmailPasswordLoginState();
}

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() {
    FirebaseAuthMethods(FirebaseAuth.instance).loginWithEmail(
      email: emailController.text, 
      password: passwordController.text, 
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Logmap',
            style: TextStyle(fontSize: 50),
          ),
          Image.asset(logMapLogo),
          const Text(
            'Login',
            style: TextStyle(fontSize: 35),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: emailController,
              hintText: 'Email',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: passwordController,
              hintText: 'Senha'),
          ),
          const SizedBox(height: 13),
          LoginButton(
            text: 'Entrar', 
            icon: Icons.login, 
            color: Colors.greenAccent.shade700, 
            loginMethod: loginUser,
            height: 13,
            width: 40,
          ),
          SignUpButton(
            text: 'Criar Conta', 
            icon: Icons.accessibility_new, 
            color: Colors.greenAccent.shade700, 
            height: 13,
            width: 40,
          ),
        ],
      ),
    );
  }
}


class LoginButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;
  final double height;
  final double width;
   
  const LoginButton(
    {super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
    required this.height,
    required this.width,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: () => loginMethod(), 
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ), 
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
          backgroundColor: color,
        ), 
        label: Text(text),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final double height;
  final double width;
   
  const SignUpButton(
    {super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.height,
    required this.width,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.pushNamed(context, '/signup');
        }, 
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ), 
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
          backgroundColor: color,
        ), 
        label: Text(text),
      ),
    );
  }
}