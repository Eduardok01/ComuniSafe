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
  Color _backgroundColor = const Color(0xFFF4E6D0); // color de fondo predeterminado

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

  Widget _buildCampoAlineado(String titulo, String valor) {
    return Container(
      color: _backgroundColor,  // Aquí aplica el color dinámico
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 4),
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
            ),
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
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _colorOpcion(const Color(0xFFFFFFFF)), // Blanco
                        _colorOpcion(const Color(0xFFF4E6D0)),
                        _colorOpcion(const Color(0xFFFEEED9)),
                        _colorOpcion(Colors.blue.shade50),
                        _colorOpcion(Colors.green.shade50),
                        _colorOpcion(Colors.pink.shade50),
                        _colorOpcion(Colors.amber.shade100),
                        _colorOpcion(const Color(0xFFE0F7FA)), // cian claro
                        _colorOpcion(const Color(0xFFFFF9C4)), // amarillo pálido
                        _colorOpcion(const Color(0xFFFFEBEE)), // rosa pálido
                        _colorOpcion(const Color(0xFFE8F5E9)), // verde muy claro
                        _colorOpcion(const Color(0xFFE3F2FD)), // azul muy claro
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
                    color: const Color(0xFFF9DFA4), // Color fijo para las cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCampoAlineado('Nombre', u.name),
                          _buildCampoAlineado('Correo', u.correo),
                          _buildCampoAlineado('Teléfono', u.phone),
                          _buildCampoAlineado('Rol', u.rol),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Editar usuario',
                                onPressed: () => _editarUsuario(usuarioMap),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Eliminar usuario',
                                onPressed: () => _eliminarUsuario(u.uid, u.name),
                              ),
                            ],
                          ),
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
    );
  }
}
