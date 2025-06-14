import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/env_config.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? usuario;
  bool isLoading = true;
  String error = '';
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController correoController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    correoController = TextEditingController();
    phoneController = TextEditingController();
    obtenerPerfil();
  }

  Future<void> obtenerPerfil() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            error = 'Usuario no autenticado';
            isLoading = false;
          });
        }
        return;
      }

      String? idToken = await user.getIdToken();

      final response = await http.get(
        Uri.parse('http://${EnvConfig.baseUrl}:8080/api/auth/perfil'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (mounted) {
          setState(() {
            usuario = body;
            isLoading = false;

            // Setear valores a los controllers para edición
            nameController.text = usuario?['name'] ?? '';
            correoController.text = usuario?['correo'] ?? '';
            phoneController.text = usuario?['phone'] ?? '';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            error = 'Error al cargar perfil: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Error inesperado: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

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

      final Map<String, dynamic> datosActualizar = {
        "name": nameController.text.trim(),
        "correo": correoController.text.trim(),
        "phone": phoneController.text.trim(),
      };

      final response = await http.put(
        Uri.parse('http://${EnvConfig.baseUrl}:8080/api/auth/perfil'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(datosActualizar),
      );

      if (response.statusCode == 200) {
        // Actualizar localmente
        setState(() {
          usuario!['name'] = nameController.text.trim();
          usuario!['correo'] = correoController.text.trim();
          usuario!['phone'] = phoneController.text.trim();
          isEditing = false;
          isLoading = false;
          error = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      } else {
        setState(() {
          error = 'Error al actualizar perfil: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error inesperado al actualizar: $e';
        isLoading = false;
      });
    }
  }

  void mostrarDialogoCambioClave() {
    final _passwordController = TextEditingController();
    final _formPassKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: _formPassKey,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_formPassKey.currentState!.validate()) return;

                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.updatePassword(_passwordController.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada')),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar contraseña: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFD2C0A5),
        actions: [
          if (!isLoading && error.isEmpty)
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (isEditing) {
                  guardarCambios();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildEditableCampo('Nombre', nameController, enabled: isEditing),
              _buildEditableCampo('Correo', correoController,
                  enabled: isEditing,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return 'Ingrese un correo válido';
                    }
                    return null;
                  }),
              _buildEditableCampo('Teléfono', phoneController,
                  enabled: isEditing,
                  keyboardType: TextInputType.phone),
              //_buildDato('Rol', usuario?['rol']),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: mostrarDialogoCambioClave,
                icon: const Icon(Icons.lock),
                label: const Text('Cambiar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCampo(
      String titulo,
      TextEditingController controller, {
        bool enabled = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: titulo,
          border: enabled
              ? const OutlineInputBorder()
              : InputBorder.none,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade200,
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
          Text(valor ?? ''),
        ],
      ),
    );
  }
}
