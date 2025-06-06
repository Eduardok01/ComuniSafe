import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EAD7),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const LoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
