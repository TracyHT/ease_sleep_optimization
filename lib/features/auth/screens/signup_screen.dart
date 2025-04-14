import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle sign up
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
