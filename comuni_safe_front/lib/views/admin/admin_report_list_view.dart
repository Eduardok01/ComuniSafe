import 'package:flutter/material.dart';
import '../../models/reporte.dart';
import '../../services/reporte_service.dart';

class AdminReportListView extends StatefulWidget {
  const AdminReportListView({super.key});

  @override
  State<AdminReportListView> createState() => _AdminReportListViewState();
}

class _AdminReportListViewState extends State<AdminReportListView> {
  late Future<List<Reporte>> _futureReportes;

  @override
  void initState() {
    super.initState();
    _futureReportes = ReporteService.obtenerReportes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes generados'),
        backgroundColor: const Color(0xFF3E3023),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFFEEED9),
      body: FutureBuilder<List<Reporte>>(
        future: _futureReportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay reportes disponibles'));
          }

          final reportes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final reporte = reportes[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: ListTile(
                  title: Text(reporte.tipo.toUpperCase()),
                  subtitle: Text(reporte.descripcion ?? 'Sin descripción'),
                  trailing: Icon(
                    reporte.pendiente ? Icons.pending_actions : Icons.check_circle,
                    color: reporte.pendiente ? Colors.orange : Colors.green,
                  ),
                  onTap: () {
                    // Podrías abrir una vista con detalles del reporte
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
