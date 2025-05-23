import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Home screen'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login screen'),
            ),
          ],
        ),
      ),
    );
  }
}
