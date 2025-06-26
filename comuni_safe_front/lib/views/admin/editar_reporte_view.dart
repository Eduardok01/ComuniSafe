import 'package:flutter/material.dart';
import '../../services/reporte_service.dart';
import '../../models/reporte.dart';

class EditarReporteView extends StatefulWidget {
  final Reporte reporte;

  const EditarReporteView({Key? key, required this.reporte}) : super(key: key);

  @override
  State<EditarReporteView> createState() => _EditarReporteViewState();
}

class _EditarReporteViewState extends State<EditarReporteView> {
  late TextEditingController _tipoController;
  late TextEditingController _descripcionController;
  bool _pendiente = true;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _direccionController;
  late DateTime _fechaHora;
  late TextEditingController _usuarioIdController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color colorPrincipal = const Color(0xFFE2734B);
  final Color colorFondo = const Color(0xFFF4E6D0);

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.reporte.tipo);
    _descripcionController = TextEditingController(text: widget.reporte.descripcion);
    _pendiente = widget.reporte.pendiente ?? true;
    _latitudController = TextEditingController(text: widget.reporte.latitud?.toString() ?? '');
    _longitudController = TextEditingController(text: widget.reporte.longitud?.toString() ?? '');
    _direccionController = TextEditingController(text: widget.reporte.direccion);
    _fechaHora = widget.reporte.fechaHora ?? DateTime.now();
    _usuarioIdController = TextEditingController(text: widget.reporte.usuarioId ?? '');
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descripcionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _direccionController.dispose();
    _usuarioIdController.dispose();
    super.dispose();
  }

  Future<bool> _showMessageDialog(BuildContext dialogContext, String title, String message, {Color? titleColor}) async {
    return await showDialog<bool>(
      context: dialogContext,
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
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedReporte = Reporte(
      id: widget.reporte.id,
      tipo: _tipoController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      pendiente: _pendiente,
      latitud: double.tryParse(_latitudController.text.trim()) ?? 0.0,
      longitud: double.tryParse(_longitudController.text.trim()) ?? 0.0,
      direccion: _direccionController.text.trim(),
      fechaHora: _fechaHora,
      usuarioId: _usuarioIdController.text.trim(),
    );

    final success = await ReporteService.actualizarReporte(updatedReporte);

    if (!mounted) return;
    setState(() => _isLoading = false);

    await _showMessageDialog(
      context,
      success ? '¡Reporte actualizado!' : 'Error',
      success ? 'Los cambios se guardaron correctamente.' : 'Error al actualizar el reporte.',
      titleColor: success ? Colors.green : Colors.red,
    );
  }

  Future<void> _eliminarReporte() async {
    if (widget.reporte.id == null) {
      await _showMessageDialog(context, 'Error', 'Reporte no tiene ID válido para eliminar', titleColor: Colors.red);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este reporte?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await ReporteService.eliminarReporte(widget.reporte.id!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    await _showMessageDialog(
      context,
      success ? '¡Reporte eliminado!' : 'Error',
      success ? 'El reporte se eliminó correctamente.' : 'Error al eliminar el reporte.',
      titleColor: success ? Colors.green : Colors.red,
    );
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
        automaticallyImplyLeading: true,
        title: const Text('Editar Reporte'),
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _eliminarReporte,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tipoController,
                decoration: _inputDecoration('Tipo'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un tipo';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: _inputDecoration('Descripción'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese una descripción';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Pendiente'),
                value: _pendiente,
                onChanged: (val) => setState(() => _pendiente = val),
                activeColor: colorPrincipal,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _latitudController,
                decoration: _inputDecoration('Latitud'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese latitud';
                  if (double.tryParse(value) == null) return 'Latitud inválida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _longitudController,
                decoration: _inputDecoration('Longitud'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese longitud';
                  if (double.tryParse(value) == null) return 'Longitud inválida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionController,
                decoration: _inputDecoration('Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese una dirección';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usuarioIdController,
                decoration: _inputDecoration('ID Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese ID de usuario';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
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
