import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? usuario;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    obtenerPerfil();
  }

  Future<void> obtenerPerfil() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = 'Usuario no autenticado';
          isLoading = false;
        });
        return;
      }

      String? idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          error = 'No se pudo obtener el token de autenticación';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://comunisafe.web.app/api/auth/perfil'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          usuario = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error al cargar perfil: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFD2C0A5),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDato('Nombre', usuario?['name']),
            _buildDato('Correo', usuario?['correo']),
            _buildDato('Teléfono', usuario?['phone']),
            _buildDato('Rol', usuario?['rol']),
          ],
        ),
      ),
    );
  }

  Widget _buildDato(String titulo, String? valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text('$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(valor ?? 'No disponible'),
        ],
      ),
    );
  }
}
