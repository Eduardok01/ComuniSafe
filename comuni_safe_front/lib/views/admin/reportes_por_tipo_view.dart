import 'package:flutter/material.dart';
import '../../models/reporte.dart';
import '../../services/reporte_service.dart';
import 'editar_reporte_view.dart';

class ReportesPorTipoView extends StatefulWidget {
  final String tipoReporte;

  const ReportesPorTipoView({super.key, required this.tipoReporte});

  @override
  State<ReportesPorTipoView> createState() => _ReportesPorTipoViewState();
}

class _ReportesPorTipoViewState extends State<ReportesPorTipoView> {
  late Future<List<Reporte>> _futureReportes;

  final Map<String, String> titulosLegibles = {
    'microtrafico': 'Microtráfico',
    'uso_indebido': 'Uso indebido de espacios',
    'robo': 'Robo o Asalto',
    'medica': 'Emergencia médica',
  };

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  void _cargarReportes() {
    _futureReportes = ReporteService.obtenerPorTipo(widget.tipoReporte.toLowerCase());
  }

  Future<void> _mostrarMensajeDialog(String titulo, String mensaje,
      {Color titleColor = Colors.black}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: titleColor,
          ),
        ),
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Ok',
                style:
                TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarReporte(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Estás Eliminando un reporte!!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: const Text(
          '¿Estás seguro de eliminar este reporte?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ReporteService.eliminarReporte(id);
      if (success) {
        await _mostrarMensajeDialog(
          '¡Reporte eliminado!',
          'El reporte fue eliminado correctamente.',
          titleColor: Colors.green,
        );
        setState(() {
          _cargarReportes();
        });
      } else {
        await _mostrarMensajeDialog(
          'Error',
          'Error eliminando reporte.',
          titleColor: Colors.red,
        );
      }
    }
  }

  void _editarReporte(Reporte reporte) async {
    final actualizado = await Navigator.push<Reporte?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarReporteView(reporte: reporte),
      ),
    );

    if (actualizado != null) {
      setState(() {
        _cargarReportes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloVisible = titulosLegibles[widget.tipoReporte] ?? widget.tipoReporte;

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3CD), // Fondo crema
      appBar: AppBar(
        title: Text(
          '$tituloVisible',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFD26033), // Naranja Admin
        iconTheme: const IconThemeData(color: Colors.black), // Color del ícono de "back"
      ),
      body: FutureBuilder<List<Reporte>>(
        future: _futureReportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reportes = snapshot.data!;
          if (reportes.isEmpty) {
            return const Center(child: Text('No hay reportes para este tipo'));
          }
          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEEED9), // Color de tarjetas igual a admin
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(reporte.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Dirección: ${reporte.direccion}\n'
                        'Pendiente: ${reporte.pendiente ? "Sí" : "No"}\n'
                        'Reportado por: ${reporte.nombreUsuario ?? reporte.usuarioId}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => _editarReporte(reporte),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarReporte(reporte.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
