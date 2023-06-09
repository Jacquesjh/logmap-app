import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logmap/services/auth.dart';
import 'package:logmap/shared/widgets/custom_passwordfield.dart';
import 'package:logmap/shared/widgets/custom_textfield.dart';
import 'package:logmap/shared/icons.dart';

class EmailPasswordLogin extends StatefulWidget {
  const EmailPasswordLogin({Key? key}) : super(key: key);

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
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: CustomPasswordField(
              controller: passwordController,
              hintText: 'Senha',
            ),
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

  const LoginButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.loginMethod,
    required this.height,
    required this.width,
  }) : super(key: key);

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
