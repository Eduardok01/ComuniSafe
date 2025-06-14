import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../models/usuario.dart';
import '../views/admin/crear_usuario_view.dart';
import '../views/admin/editar_usuario_view.dart';

class AdminUserListView extends StatefulWidget {
  final String token;

  const AdminUserListView({super.key, required this.token});

  @override
  State<AdminUserListView> createState() => _AdminUserListViewState();
}

class _AdminUserListViewState extends State<AdminUserListView> {
  late Future<List<Usuario>> _usuarios;
  Color _backgroundColor = const Color(0xFFF4E6D0);

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
          token: widget.token,
        ),
      ),
    );

    if (resultado == true) {
      _refreshUsuarios();
    }
  }

  Future<void> _eliminarUsuario(String uid, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar usuario $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await UsuarioService().eliminarUsuario(uid, widget.token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario $nombre eliminado')),
        );
        _refreshUsuarios();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error eliminando usuario')),
        );
      }
    }
  }

  Widget _buildCampoConBotonFuera(String titulo, String valor, {Widget? boton}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      '$titulo:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      valor,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (boton != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: boton,
            ),
        ],
      ),
    );
  }

  void _mostrarSelectorColor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona un color de fondo:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _colorOpcion(const Color(0xFFFFFFFF)),
                        _colorOpcion(const Color(0xFFF4E6D0)),
                        _colorOpcion(const Color(0xFFFEEED9)),
                        _colorOpcion(const Color(0xFFE0F7FA)),
                        _colorOpcion(const Color(0xFFFFF9C4)),
                        _colorOpcion(const Color(0xFFFFEBEE)),
                        _colorOpcion(const Color(0xFFE8F5E9)),
                        _colorOpcion(const Color(0xFFE3F2FD)),
                        _colorOpcion(const Color(0xFFFFF0E6)),
                        _colorOpcion(const Color(0xFFFFD6B8)),
                        _colorOpcion(const Color(0xFFFFB07A)),
                        _colorOpcion(const Color(0xFFE2734B)),
                        _colorOpcion(const Color(0xFFCC5F3F)),
                        _colorOpcion(const Color(0xFF993F2B)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _colorOpcion(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }

  void _abrirCrearUsuario() async {
    final creado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearUsuarioView(token: widget.token),
      ),
    );

    if (creado == true) {
      _refreshUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios registrados'),
        backgroundColor: const Color(0xFFE2734B),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Cambiar color de fondo',
            onPressed: _mostrarSelectorColor,
          ),
        ],
      ),
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
            return Container(
              color: _backgroundColor,
              child: RefreshIndicator(
                onRefresh: _refreshUsuarios,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(child: Text('No hay usuarios registrados.')),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: _backgroundColor,
            child: RefreshIndicator(
              onRefresh: _refreshUsuarios,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final u = usuarios[index];
                  final usuarioMap = {
                    'uid': u.uid,
                    'name': u.name,
                    'correo': u.correo,
                    'phone': u.phone,
                    'rol': u.rol,
                  };
                  return Card(
                    color: const Color(0xFFF9DFA4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCampoConBotonFuera(
                            'Nombre',
                            u.name,
                            boton: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: 'Editar usuario',
                              onPressed: () => _editarUsuario(usuarioMap),
                            ),
                          ),
                          _buildCampoConBotonFuera('Correo', u.correo),
                          _buildCampoConBotonFuera(
                            'Teléfono',
                            u.phone,
                            boton: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              tooltip: 'Eliminar usuario',
                              onPressed: () => _eliminarUsuario(u.uid, u.name),
                            ),
                          ),
                          _buildCampoConBotonFuera('Rol', u.rol),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCrearUsuario,
        label: const Text('Nuevo Usuario'),
        icon: const Icon(Icons.person_add),
        backgroundColor: const Color(0xFFE2734B),
      ),
    );
  }
}
