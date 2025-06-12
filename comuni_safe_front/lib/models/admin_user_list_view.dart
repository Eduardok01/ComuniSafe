import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';
import '../views/admin/editar_usuario_view.dart';

class AdminUserListView extends StatefulWidget {
  final String token;

  const AdminUserListView({super.key, required this.token});

  @override
  State<AdminUserListView> createState() => _AdminUserListViewState();
}

class _AdminUserListViewState extends State<AdminUserListView> {
  late Future<List<Usuario>> _usuarios;

  @override
  void initState() {
    super.initState();
    _usuarios = UsuarioService().obtenerUsuarios(widget.token);
  }

  Future<void> _refreshUsuarios() async {
    setState(() {
      _usuarios = UsuarioService().obtenerUsuarios(widget.token);
    });
  }

  Future<void> _editarUsuario(Map<String, dynamic> usuario) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarUsuarioView(
          usuario: usuario,
          token: widget.token,  // <-- PASAMOS el token aquí
        ),
      ),
    );

    if (resultado == true) {
      _refreshUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios registrados')),
      body: FutureBuilder<List<Usuario>>(
        future: _usuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final usuarios = snapshot.data;
          if (usuarios == null || usuarios.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshUsuarios,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('No hay usuarios registrados.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshUsuarios,
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];
                // Convertir Usuario a Map para pasar a la vista editar
                final usuarioMap = {
                  'uid': u.uid,
                  'name': u.name,
                  'correo': u.correo,
                  'phone': u.phone,
                  'rol': u.rol,
                };
                return ListTile(
                  title: Text(u.name),
                  subtitle: Text('${u.correo} • ${u.phone}'),
                  trailing: Text(u.rol),
                  onTap: () => _editarUsuario(usuarioMap),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
