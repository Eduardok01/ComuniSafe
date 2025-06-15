import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../models/reporte.dart';

class ReporteService {
  static final String _baseUrl = '${EnvConfig.baseUrl}/api/reportes';

  /// Crear reporte
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
      final data = jsonDecode(response.body);
      if (data.containsKey('mensaje')) {
        print('Backend dice: ${data['mensaje']}');
      }
      return true;
    } else {
      print('Error al crear reporte: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// Obtener todos los reportes
  static Future<List<Reporte>> obtenerReportes() async {
    final url = Uri.parse(_baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Reporte.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los reportes: ${response.statusCode}');
    }
  }

  /// Obtener reportes por tipo
  static Future<List<Reporte>> obtenerPorTipo(String tipo) async {
    final url = Uri.parse('$_baseUrl/tipo/$tipo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Reporte.fromJson(e)).toList();
    } else {
      throw Exception('Error al filtrar reportes por tipo: ${response.statusCode}');
    }
  }

  /// Eliminar un reporte
  static Future<bool> eliminarReporte(String id) async {
    final url = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Reporte eliminado exitosamente');
      return true;
    } else {
      print('Error al eliminar reporte: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// Actualizar un reporte existente
  static Future<bool> actualizarReporte(Reporte reporte) async {
    final url = Uri.parse('$_baseUrl/${reporte.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reporte.toJson()),
    );

    if (response.statusCode == 200) {
      print('Reporte actualizado exitosamente');
      return true;
    } else {
      print('Error al actualizar reporte: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// Obtener el conteo de reportes por tipo
  /// Espera que el backend responda con JSON { "count": <int> }
  static Future<int> obtenerConteoPorTipo(String tipo) async {
    final url = Uri.parse('$_baseUrl/conteo/tipo/$tipo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('count')) {
        return data['count'] as int;
      } else {
        throw Exception('Respuesta inesperada del backend');
      }
    } else {
      throw Exception('Error al obtener conteo de reportes por tipo: ${response.statusCode}');
    }
  }
}
