import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:comuni_safe_front/config/env_config.dart';
import '../home/admin_home_view.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    print('Intentando login con: $email');

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final idToken = await userCredential.user?.getIdToken(true);

      if (idToken == null) {
        throw Exception("No se pudo obtener el token");
      }

      final url = Uri.parse('${EnvConfig.baseUrl}/api/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String? role = data['role'];

        print('Rol detectado en frontend: $role');
        print('Navegando a: ${role == 'admin' ? 'admin_home' : 'home'}');

        await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, 'admin_home');
        } else {
          Navigator.pushReplacementNamed(context, 'home');
        }
      } else {
        print('Login fallido con código: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('Login fallido: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Error durante el login: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content:
          Text('No se pudo conectar con el servidor o credenciales inválidas.'),
        ),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
          '654543001926-ou4pvidmql27vlkmhcb41ks3n9lbe3tc.apps.googleusercontent.com');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Inicio de sesión con Google cancelado");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken(true);

      if (idToken == null) throw Exception("No se pudo obtener el token de Google");

      final url = Uri.parse('${EnvConfig.baseUrl}/api/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta backend: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        print('Login con Google exitoso, navegando a home');
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('Login con Google fallido: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Error con Google Sign-In: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Error'),
          content: Text('Error al intentar ingresar con Google.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Inicio de sesión',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Ingresar', style: TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(height: 8),
        /*TextButton(
          onPressed: () {},
          child: const Text('¿Olvidó su contraseña?'),
        )*/
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
          ),
          icon: Image.asset('assets/google_logo.png', height: 24),
          label: const Text('Ingresar con Google'),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('o'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, 'register');
          },
          child: const Text(
            'Regístrese aquí',
            style: TextStyle(color: Colors.blueAccent),
          ),
        )
      ],
    );
  }
}
