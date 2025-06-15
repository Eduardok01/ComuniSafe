import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../config/env_config.dart';
import '../../models/reporte.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  String selectedCategory = '';
  final TextEditingController descriptionController = TextEditingController();

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget buildCategoryButton({
    required String label,
    required String imagePath,
    required Color color,
    required String categoryKey,
  }) {
    final isSelected = selectedCategory == categoryKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(70),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 1.5,
            ),
          ),
          elevation: isSelected ? 2 : 0,
        ),
        onPressed: () => selectCategory(categoryKey),
        child: Row(
          children: [
            Image.asset(imagePath, width: 36, height: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> _obtenerUbicacionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception('El servicio de ubicación está deshabilitado.');
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _showMessageDialog(
      String title,
      String message, {
        required Color titleColor,
      }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEEED9),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: message.isNotEmpty
            ? Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        )
            : null,
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



  Future<void> _enviarReporte() async {
    if (selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría')),
      );
      return;
    }

    try {
      final posicion = await _obtenerUbicacionActual();
      final usuario = FirebaseAuth.instance.currentUser;
      final uid = usuario?.uid ?? 'usuario_desconocido';

      final reporte = Reporte(
        tipo: selectedCategory,
        descripcion: descriptionController.text.trim(),
        pendiente: true,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        direccion: 'Ubicación actual',
        fechaHora: DateTime.now(),
        usuarioId: uid,
      );

      final url = Uri.parse('${EnvConfig.baseUrl}/api/reportes');
      final Map<String, dynamic> jsonReporte = reporte.toJson();

      // Ajustar fecha para quitar decimales de segundos (opcional)
      DateTime fecha = reporte.fechaHora;
      DateTime fechaSinDecimales = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        fecha.hour,
        fecha.minute,
        fecha.second,
      );
      jsonReporte['fechaHora'] = fechaSinDecimales.toIso8601String();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonReporte),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _showMessageDialog(
          '¡Reporte creado exitosamente!',
          '',
          titleColor: Colors.green,
        );


        Navigator.pop(context); // Regresa a la pantalla anterior
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2DDBC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Reporta un incidente',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E3023),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              buildCategoryButton(
                label: 'Microtráfico',
                imagePath: 'assets/microtrafico.png',
                color: Colors.yellow.shade300,
                categoryKey: 'microtrafico',
              ),
              buildCategoryButton(
                label: 'Uso indebido de espacios',
                imagePath: 'assets/espacios.png',
                color: Colors.grey.shade400,
                categoryKey: 'uso_indebido',
              ),
              buildCategoryButton(
                label: 'Robo/Asalto',
                imagePath: 'assets/robo.png',
                color: Colors.red.shade200,
                categoryKey: 'robo',
              ),
              buildCategoryButton(
                label: 'Emergencia médica',
                imagePath: 'assets/ambulancia.png',
                color: Colors.white,
                categoryKey: 'medica',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Descripción... (Opcional)',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _enviarReporte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reportar',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
