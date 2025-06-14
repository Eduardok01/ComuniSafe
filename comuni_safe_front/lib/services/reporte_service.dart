import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/reporte.dart';

class ReporteService {
  static final String _baseUrl = '${EnvConfig.baseUrl}/api/reportes';

  /// Envía el reporte al backend y devuelve true si fue exitoso.
  static Future<bool> enviarReporte(Reporte reporte) async {
    final url = Uri.parse(_baseUrl);

    final Map<String, dynamic> jsonReporte = reporte.toJson();

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
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('mensaje')) {
        print('Backend dice: ${data['mensaje']}');
      }
      return true;
    } else {
      print('Error al crear reporte: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// Obtiene todos los reportes del backend.
  static Future<List<Reporte>> obtenerReportes() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Reporte.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los reportes: ${response.statusCode}');
    }
  }
}
