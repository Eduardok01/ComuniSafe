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
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _usuarioService = UsuarioService();

  bool _isLoading = false;

  final Color colorPrincipal = const Color(0xFFE2734B);
  final Color colorFondo = const Color(0xFFF4E6D0);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.usuario['name'] ?? '');
    _correoController = TextEditingController(text: widget.usuario['correo'] ?? '');
    _telefonoController = TextEditingController(text: widget.usuario['phone'] ?? '');
    _rolController = TextEditingController(text: widget.usuario['rol'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final token = widget.token;
    if (token.isEmpty) {
      await _showMessageDialog('Token no encontrado', 'No se pudo obtener el token de autenticación.', titleColor: Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> datosActualizar = {
      'name': _nameController.text.trim(),
      'correo': _correoController.text.trim(),
      'phone': _telefonoController.text.trim(),
      'rol': _rolController.text.trim(),
    };

    if (_passwordController.text.trim().isNotEmpty) {
      datosActualizar['password'] = _passwordController.text.trim();
    }

    final success = await _usuarioService.editarUsuario(
      widget.usuario['uid'],
      datosActualizar,
      token,
    );

    setState(() => _isLoading = false);

    if (success) {
      await _showMessageDialog('¡Usuario actualizado!', 'Los cambios se guardaron correctamente.', titleColor: Colors.green);
      Navigator.pop(context, true);
    } else {
      await _showMessageDialog('Error', 'Error al actualizar el usuario.', titleColor: Colors.red);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorPrincipal),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorPrincipal),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorPrincipal, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Editar Usuario'),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.black, // texto negro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un nombre';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _correoController,
                decoration: _inputDecoration('Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un correo';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Debe ser un correo válido (ejemplo: usuario@ejemplo.com).',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telefonoController,
                decoration: _inputDecoration('Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un teléfono';
                  if (!value.startsWith('+56')) return 'El teléfono debe comenzar con +56';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Debe comenzar con "+56" seguido del número 9XXXXXXXX',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _rolController,
                decoration: _inputDecoration('Rol'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un rol';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration('Nueva contraseña (opcional)'),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Debe contener al menos 6 caracteres.\nIncluir al menos una letra mayúscula y minúscula\nDebe contener al menos un símbolo especial.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrincipal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
