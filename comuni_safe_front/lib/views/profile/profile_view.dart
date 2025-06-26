import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/env_config.dart';
import '../../models/reporte.dart';

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

  List<Reporte> reportesUsuario = [];
  bool cargandoReportes = false;

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

      final uid = user.uid;
      if (uid.isEmpty || idToken == null) {
        if (mounted) {
          setState(() {
            error = 'No se pudo obtener identificador o token';
            isLoading = false;
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/api/auth/perfil'),
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

            nameController.text = usuario?['name'] ?? '';
            correoController.text = usuario?['correo'] ?? '';
            phoneController.text = usuario?['phone'] ?? '';
          });
        }

        await obtenerReportesUsuario(uid, idToken);
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

  Future<void> obtenerReportesUsuario(String usuarioId, String idToken) async {
    setState(() {
      cargandoReportes = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/api/reportes/usuario/$usuarioId/activos'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            reportesUsuario = data.map((e) => Reporte.fromJson(e)).toList();
            cargandoReportes = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            cargandoReportes = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          cargandoReportes = false;
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
        Uri.parse('${EnvConfig.baseUrl}/api/auth/perfil'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(datosActualizar),
      );

      if (response.statusCode == 200) {
        setState(() {
          usuario!['name'] = nameController.text.trim();
          usuario!['correo'] = correoController.text.trim();
          usuario!['phone'] = phoneController.text.trim();
          isEditing = false;
          isLoading = false;
          error = '';
        });
        await _showMessageDialog('¡Perfil actualizado!', 'Tus datos se actualizaron correctamente.', titleColor: Colors.green);
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

  Widget _buildEditableCampo(
      String titulo,
      TextEditingController controller, {
        bool enabled = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: titulo,
          border: enabled ? const OutlineInputBorder() : InputBorder.none,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildReporteCard(Reporte reporte) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: _ReporteDescripcionExpandable(
          reporte: reporte,
          onEditar: () => mostrarDialogoEditarReporte(reporte),
          onEliminar: () => eliminarReporte(reporte),
        ),
      ),
    );
  }

  Future<void> mostrarDialogoEditarReporte(Reporte reporte) async {
    final _formKeyReporte = GlobalKey<FormState>();
    final descripcionController = TextEditingController(text: reporte.descripcion);
    final tipoController = TextEditingController(text: reporte.tipo);

    bool guardando = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Editar Reporte'),
            content: Form(
              key: _formKeyReporte,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 4,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Debe ingresar una descripción';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: tipoController,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Debe ingresar un tipo';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: guardando ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: guardando
                    ? null
                    : () async {
                  if (!_formKeyReporte.currentState!.validate()) return;

                  setStateDialog(() {
                    guardando = true;
                  });

                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      throw Exception('Usuario no autenticado');
                    }
                    String? idTokenNullable = await user.getIdToken();
                    if (idTokenNullable == null) {
                      throw Exception('No se pudo obtener el token de autenticación');
                    }
                    String idToken = idTokenNullable;

                    final Map<String, dynamic> datosActualizar = {
                      'descripcion': descripcionController.text.trim(),
                      'tipo': tipoController.text.trim(),
                    };

                    final response = await http.put(
                      Uri.parse('${EnvConfig.baseUrl}/api/reportes/${reporte.id}'),
                      headers: {
                        'Authorization': 'Bearer $idToken',
                        'Content-Type': 'application/json',
                      },
                      body: json.encode(datosActualizar),
                    );

                    if (response.statusCode == 200) {
                      setState(() {
                        reporte.descripcion = descripcionController.text.trim();
                        reporte.tipo = tipoController.text.trim();
                      });
                      Navigator.of(context).pop();
                      await _showMessageDialog('Reporte actualizado', 'El reporte fue actualizado correctamente.', titleColor: Colors.green);
                    } else {
                      await _showMessageDialog('Error', 'No se pudo actualizar el reporte: ${response.statusCode}', titleColor: Colors.red);
                    }
                  } catch (e) {
                    await _showMessageDialog('Error', 'Error al actualizar reporte: $e', titleColor: Colors.red);
                  } finally {
                    setStateDialog(() {
                      guardando = false;
                    });
                  }
                },
                child: guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> eliminarReporte(Reporte reporte) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro que deseas eliminar este reporte?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      cargandoReportes = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          error = 'Usuario no autenticado';
          cargandoReportes = false;
        });
        return;
      }
      String? idTokenNullable = await user.getIdToken();
      if (idTokenNullable == null) {
        setState(() {
          error = 'No se pudo obtener el token de autenticación';
          cargandoReportes = false;
        });
        return;
      }
      String idToken = idTokenNullable;
      final response = await http.delete(
        Uri.parse('${EnvConfig.baseUrl}/api/reportes/${reporte.id}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          reportesUsuario.removeWhere((r) => r.id == reporte.id);
          cargandoReportes = false;
        });
        await _showMessageDialog('Reporte eliminado', 'El reporte fue eliminado correctamente.', titleColor: Colors.green);
      } else {
        setState(() {
          cargandoReportes = false;
        });
        await _showMessageDialog('Error', 'No se pudo eliminar el reporte: ${response.statusCode}', titleColor: Colors.red);
      }
    } catch (e) {
      setState(() {
        cargandoReportes = false;
      });
      await _showMessageDialog('Error', 'Error al eliminar reporte: $e', titleColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFFE2734B),
        actions: [
          if (!isLoading && error.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: () {
                  if (isEditing) {
                    guardarCambios();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                icon: Icon(
                  isEditing ? Icons.save : Icons.edit,
                  color: Colors.black,
                ),
                label: Text(
                  isEditing ? 'Guardar' : 'Editar datos',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF5EE),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildEditableCampo('Nombre', nameController, enabled: isEditing),
                  _buildEditableCampo(
                    'Correo',
                    correoController,
                    enabled: isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                  _buildEditableCampo('Teléfono', phoneController, enabled: isEditing, keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: mostrarDialogoCambioClave,
                    icon: const Icon(Icons.lock),
                    label: const Text('Cambiar contraseña'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('Reportes Activos:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            cargandoReportes
                ? const Center(child: CircularProgressIndicator())
                : reportesUsuario.isEmpty
                ? const Text('No tienes reportes activos.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reportesUsuario.length,
              itemBuilder: (context, index) {
                final reporte = reportesUsuario[index];
                return _buildReporteCard(reporte);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReporteDescripcionExpandable extends StatefulWidget {
  final Reporte reporte;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ReporteDescripcionExpandable({
    Key? key,
    required this.reporte,
    required this.onEditar,
    required this.onEliminar,
  }) : super(key: key);

  @override
  State<_ReporteDescripcionExpandable> createState() => _ReporteDescripcionExpandableState();
}

class _ReporteDescripcionExpandableState extends State<_ReporteDescripcionExpandable> {
  bool expanded = false;

  String getTipoTexto(String tipo) {
    switch (tipo) {
      case 'microtrafico':
        return 'Microtráfico';
      case 'medica':
        return 'Emergencia Médica';
      case 'uso_indebido':
        return 'Uso indebido de espacios';
      case 'robo':
        return 'Robo/Asalto';
      default:
        return tipo;
    }
  }

  String getTipoImagePath(String tipo) {
    switch (tipo) {
      case 'microtrafico':
        return 'assets/microtrafico.png';
      case 'medica':
        return 'assets/ambulancia.png';
      case 'uso_indebido':
        return 'assets/espacios.png';
      case 'robo':
        return 'assets/robo.png';
      default:
        return 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final descripcion = widget.reporte.descripcion;
    final tipoRaw = widget.reporte.tipo;
    final tipoTexto = getTipoTexto(tipoRaw);
    final tipoImage = getTipoImagePath(tipoRaw);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          descripcion,
          style: const TextStyle(fontSize: 16),
          maxLines: expanded ? null : 3,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (descripcion.length > 100)
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Text(
              expanded ? 'Leer menos' : 'Leer más',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Image.asset(
              tipoImage,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 24, height: 24),
            ),
            const SizedBox(width: 6),
            Text(
              tipoTexto,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.reporte.pendiente) const Icon(Icons.warning, color: Colors.red),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar reporte',
              onPressed: widget.onEditar,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar reporte',
              onPressed: widget.onEliminar,
            ),
          ],
        ),
      ],
    );
  }
}
