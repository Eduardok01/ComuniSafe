import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/usuario.dart';

class UsuarioService {
  final String baseUrl = 'http://192.168.0.19:8080/api/admin'; // Cambia por tu URL real

  Future<List<Usuario>> obtenerUsuarios(String token) async {
    final url = Uri.parse('$baseUrl/usuarios');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  Future<bool> eliminarUsuario(String uid, String token) async {
    final url = Uri.parse('$baseUrl/usuarios/$uid');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> editarUsuario(String uid, Map<String, dynamic> datos, String token) async {
    final url = Uri.parse('$baseUrl/usuarios/$uid');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(datos),
    );

    return response.statusCode == 200;
  }

  Future<Usuario> crearUsuario(Map<String, dynamic> datos) async {
    // Implementar creación si quieres
    throw UnimplementedError();
  }
}
