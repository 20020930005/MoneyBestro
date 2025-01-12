import 'package:flutter/material.dart';
import '../utils/auth/auth_service.dart';
import '../utils/my_button.dart';
import '../utils/my_textfield.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordEditingController =
      TextEditingController();

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) {
    final _auth = AuthService();

    if (_passwordEditingController.text == _confirmPasswordEditingController.text) {
      try {
        _auth.signUpWithEmailPassword(
        _emailEditingController.text,
        _passwordEditingController.text,
      );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(e.toString()),
          ),
        );
      }
    }
    else {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            content: Text('Password do not match!'),
          ),
        );
    }
  }

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              "Let's create an account for you!",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 16),
            ),
            const SizedBox(
              height: 50,
            ),
            MyTextfield(
              hintText: 'Email',
              obscureText: false,
              controller: _emailEditingController,
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextfield(
              hintText: 'Password',
              obscureText: true,
              controller: _passwordEditingController,
            ),
            const SizedBox(
              height: 10,
            ),
            MyTextfield(
              hintText: 'Confirm password',
              obscureText: true,
              controller: _confirmPasswordEditingController,
            ),
            const SizedBox(
              height: 25,
            ),
            MyButton(
              text: 'Register',
              onTap: () => register(context),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Already have an account ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: const Text(
                    "login now",
                    style: TextStyle(
                      color: Color.fromARGB(255, 52, 52, 52),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
