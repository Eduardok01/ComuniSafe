import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _telefonoController = TextEditingController(text: '+56');
  final TextEditingController _passwordController = TextEditingController();
  String _rol = 'usuario';

  bool _cargando = false;

  Future<void> _showMessageDialog(String title, String message, {Color titleColor = Colors.black}) {
    return showDialog(
      context: context,
      barrierDismissible: false, // No cerrar tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
    });

    final url = Uri.parse('${EnvConfig.baseUrl}/api/admin/usuarios');
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
        await _showMessageDialog(
          '¡Usuario creado!',
          'El usuario ${_nombreController.text.trim()} fue creado correctamente.',
          titleColor: Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        final error = jsonDecode(response.body);
        await _showMessageDialog(
          'Error',
          'Error: ${error["message"] ?? response.body}',
          titleColor: Colors.red,
        );
      }
    } catch (e) {
      await _showMessageDialog(
        'Error de red',
        e.toString(),
        titleColor: Colors.red,
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
    const textoExplicativoStyle = TextStyle(fontSize: 12, color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Usuario'),
        backgroundColor: const Color(0xFFE2734B),
      ),
      backgroundColor: const Color(0xFFFFF5EE),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Formulario de Registro',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE2734B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                  const Text(
                    'Debe ser un correo válido con formato: usuario@ejemplo.com',
                    style: textoExplicativoStyle,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(12), // +56 + 9 dígitos = 12 caracteres
                      _TelefonoFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      if (!value.startsWith('+56')) return 'Debe comenzar con +56';
                      if (value.length != 12) return 'Debe tener 9 dígitos luego del +56';
                      return null;
                    },
                  ),
                  const Text(
                    'Debe comenzar con +56 seguido de 9XXXXXXXX\nEjemplo completo: +56912345678',
                    style: textoExplicativoStyle,
                  ),
                  const SizedBox(height: 8),
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
                  const Text(
                    'Debe contener al menos 6 caracteres.\nIncluir al menos una letra mayúscula y minúscula\nDebe contener al menos un símbolo especial.',
                    style: textoExplicativoStyle,
                  ),
                  const SizedBox(height: 8),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _cargando ? null : _crearUsuario,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Formatter personalizado para bloquear y mantener "+56"
class _TelefonoFormatter extends TextInputFormatter {
  static const prefix = '+56';

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.text.startsWith(prefix)) {
      return oldValue;
    }
    // Evitar borrar el prefijo +56
    if (newValue.selection.baseOffset < prefix.length) {
      return oldValue;
    }
    // Limitar la longitud total a 12 caracteres (+56 + 9 dígitos)
    if (newValue.text.length > 12) {
      return oldValue;
    }
    // Permitir solo dígitos después del prefijo
    final afterPrefix = newValue.text.substring(prefix.length);
    final onlyDigits = RegExp(r'^\d*$');
    if (!onlyDigits.hasMatch(afterPrefix)) {
      return oldValue;
    }
    return newValue;
  }
}
