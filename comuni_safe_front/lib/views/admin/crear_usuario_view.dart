import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/env_config.dart';

class CrearUsuarioView extends StatefulWidget {
  final String token;

  const CrearUsuarioView({super.key, required this.token});

  @override
  State<CrearUsuarioView> createState() => _CrearUsuarioViewState();
}

class _CrearUsuarioViewState extends State<CrearUsuarioView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  //xD
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _rol = 'usuario'; // valor por defecto

  bool _cargando = false;

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
    });

    final url = Uri.parse('${EnvConfig.baseUrl}/api/admin/usuarios'); // Cambia si usas https o IP real
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final body = jsonEncode({
      'name': _nombreController.text.trim(),
      'correo': _correoController.text.trim(),
      'phone': _telefonoController.text.trim(),
      'password': _passwordController.text,
      'rol': _rol,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
        Navigator.pop(context, true); // Devuelve true para refrescar la lista
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error["message"] ?? response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Usuario'),
        backgroundColor: const Color(0xFFE2734B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) return 'Correo inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _rol = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _cargando
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.person_add),
                label: const Text('Crear usuario'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE2734B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _cargando ? null : _crearUsuario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
