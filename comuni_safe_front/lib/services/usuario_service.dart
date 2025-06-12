import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  final String baseUrl = 'http://192.168.0.19:8080/api/admin';

  Future<List<Usuario>> obtenerUsuarios(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios: ${response.statusCode}');
    }
  }

  Future<bool> editarUsuario(String uid, Map<String, dynamic> datosActualizados, String token) async {
    final url = Uri.parse('$baseUrl/usuarios/$uid');

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(datosActualizados),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al editar usuario: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
