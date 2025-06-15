import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReporteFiltradoView extends StatelessWidget {
  final String tipo;

  const ReporteFiltradoView({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes de $tipo'),
        backgroundColor: const Color(0xFFD26033),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF4E3CD),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .where('tipo', isEqualTo: tipo)
            .orderBy('fechaHora', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reportes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reportes = snapshot.data!.docs;

          if (reportes.isEmpty) {
            return const Center(child: Text('No hay reportes para mostrar'));
          }

          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final doc = reportes[index];
              final data = doc.data() as Map<String, dynamic>;

              final fecha = data['fechaHora']?.toDate().toString().substring(0, 16) ?? 'Sin fecha';
              final pendiente = data['pendiente'] ?? true;

              return Card(
                color: const Color(0xFFFEEED9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['descripcion'] ?? 'Sin descripción'),
                  subtitle: Text('Dirección: ${data['direccion'] ?? 'N/A'}\nFecha: $fecha'),
                  trailing: IconButton(
                    icon: Icon(
                      pendiente ? Icons.warning : Icons.check_circle,
                      color: pendiente ? Colors.red : Colors.green,
                    ),
                    onPressed: () async {
                      try {
                        await doc.reference.update({'pendiente': !pendiente});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              pendiente
                                  ? 'Reporte marcado como resuelto'
                                  : 'Reporte marcado como pendiente',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar: $e')),
                        );
                      }
                    },
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
