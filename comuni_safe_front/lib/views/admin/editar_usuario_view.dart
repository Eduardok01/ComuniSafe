import 'package:flutter/material.dart';
import '../../services/usuario_service.dart';

class EditarUsuarioView extends StatefulWidget {
  final Map<String, dynamic> usuario;
  final String token; // <-- Recibimos el token aquí

  const EditarUsuarioView({Key? key, required this.usuario, required this.token}) : super(key: key);

  @override
  State<EditarUsuarioView> createState() => _EditarUsuarioViewState();
}

class _EditarUsuarioViewState extends State<EditarUsuarioView> {
  late TextEditingController _nameController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _rolController;

  final _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario['name'] ?? '');
    _correoController = TextEditingController(text: widget.usuario['correo'] ?? '');
    _telefonoController = TextEditingController(text: widget.usuario['phone'] ?? '');
    _rolController = TextEditingController(text: widget.usuario['rol'] ?? '');
  }

  Future<void> _guardarCambios() async {
    final token = widget.token; // Usamos el token que recibimos

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token no encontrado')),
      );
      return;
    }

    final success = await _usuarioService.editarUsuario(
      widget.usuario['uid'],
      {
        'name': _nameController.text.trim(),
        'correo': _correoController.text.trim(),
        'phone': _telefonoController.text.trim(),
        'rol': _rolController.text.trim(),
      },
      token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el usuario')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _correoController, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: _rolController, decoration: const InputDecoration(labelText: 'Rol')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarCambios,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
