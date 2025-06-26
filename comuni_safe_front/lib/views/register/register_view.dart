import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comuni_safe_front/config/env_config.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final _nameRegex = RegExp(r'^[A-Za-zÀ-ÿ]+(\s[A-Za-zÀ-ÿ]+)+$');
  // Cambié el regex para que valide +569 seguido de 8 dígitos
  final _chileMobilePhoneRegex = RegExp(r'^\+569\d{8}$');
  final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$');

  Future<void> _showMessageDialog(String title, String message, {Color? titleColor}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.black87,
            ),
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String phone = '+56${phoneController.text.trim()}'; // agrego +56 fijo
    final String name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phoneController.text.isEmpty || name.isEmpty) {
      await _showMessageDialog('Campos incompletos', 'Por favor, completa todos los campos', titleColor: Colors.red);
      return;
    }

    if (!_nameRegex.hasMatch(name)) {
      await _showMessageDialog('Nombre inválido', 'Debe ingresar nombre y apellido válidos', titleColor: Colors.red);
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      await _showMessageDialog('Correo inválido', 'Por favor, ingresa un correo electrónico válido', titleColor: Colors.red);
      return;
    }

    if (!_chileMobilePhoneRegex.hasMatch(phone)) {
      await _showMessageDialog(
        'Teléfono inválido',
        'Por favor, ingresa un número de teléfono válido (ej: 912345678)',
        titleColor: Colors.red,
      );
      return;
    }

    if (!_passwordRegex.hasMatch(password)) {
      await _showMessageDialog(
        'Contraseña inválida',
        'Debe cumplir con los requisitos',
        titleColor: Colors.red,
      );
      return;
    }

    if (password != confirmPassword) {
      await _showMessageDialog('Contraseñas no coinciden', 'Las contraseñas ingresadas no coinciden', titleColor: Colors.red);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String? idToken = await userCredential.user?.getIdToken();

      final url = Uri.parse('${EnvConfig.baseUrl}/api/auth/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'correo': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _showMessageDialog('¡Registro exitoso!', 'Tu usuario fue creado correctamente.', titleColor: Colors.green);
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        await _showMessageDialog('Error', 'Error en backend: ${response.statusCode}', titleColor: Colors.red);
      }
    } catch (e) {
      await _showMessageDialog('Error', 'Error al registrar: $e', titleColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3CD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.brown, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registro',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  buildTextField(label: 'Nombre completo', controller: nameController),

                  buildTextField(label: 'Correo electrónico',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ejemplo: usuario@ejemplo.com',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  buildTextField(label: 'Contraseña', controller: passwordController, obscureText: true),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mínimo 6 caracteres\nDebe incluir una letra mayúscula y minúscula\nDebe contener al menos un símbolo "@!#\$%"',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),

                  buildTextField(label: 'Confirmar contraseña', controller: confirmPasswordController, obscureText: true),

                  buildPhoneField(controller: phoneController),

                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7DF73),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    double paddingBottom = 6, // nuevo
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }


  Widget buildPhoneField({
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        maxLength: 9,
        decoration: InputDecoration(
          labelText: 'Teléfono',
          prefixText: '+56 ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
