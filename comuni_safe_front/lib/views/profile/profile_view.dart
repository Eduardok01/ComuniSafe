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
        print('No hay usuario autenticado');
        return;
      }

      print('Usuario autenticado UID: ${user.uid}');
      print('Usuario autenticado email: ${user.email}');

      String? idToken = await user.getIdToken();
      print('Token ID obtenido: $idToken');

      final response = await http.get(
        Uri.parse('http://192.168.0.19:8080/api/auth/perfil'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body == null || body.isEmpty) {
          setState(() {
            error = 'Perfil no encontrado en el servidor.';
            isLoading = false;
          });
          print('El cuerpo de la respuesta está vacío o es nulo');
          return;
        }

        setState(() {
          usuario = body;
          isLoading = false;
        });
        print('Perfil cargado correctamente: $usuario');
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'Perfil no encontrado (404).';
          isLoading = false;
        });
        print('Perfil no encontrado en backend');
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        setState(() {
          error = 'Error al cargar perfil: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Excepción capturada: $e');
      setState(() {
        error = 'Error inesperado: $e';
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
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(valor ?? 'No disponible'),
        ],
      ),
    );
  }
}
