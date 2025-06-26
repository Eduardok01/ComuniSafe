class Reporte {
  String? id;
  String tipo;
  String descripcion;
  bool pendiente;
  double latitud;
  double longitud;
  String direccion;
  DateTime fechaHora;
  String usuarioId;

  String? nombreUsuario;
  String? correoUsuario;
  String? rolUsuario;

  Reporte({
    this.id,
    required this.tipo,
    required this.descripcion,
    required this.pendiente,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.fechaHora,
    required this.usuarioId,
    this.nombreUsuario,
    this.correoUsuario,
    this.rolUsuario,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    DateTime fecha;

    if (json['fechaHora'] is String) {
      fecha = DateTime.parse(json['fechaHora']);
    } else if (json['fechaHora'] is Map<String, dynamic>) {
      final timestampMap = json['fechaHora'] as Map<String, dynamic>;
      int seconds = timestampMap['_seconds'] ?? timestampMap['seconds'] ?? 0;
      int nanoseconds = timestampMap['_nanoseconds'] ?? timestampMap['nanoseconds'] ?? 0;
      fecha = DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + nanoseconds ~/ 1000000);
    } else {
      throw Exception('Tipo de fechaHora no reconocido: ${json['fechaHora'].runtimeType}');
    }

    return Reporte(
      id: json['id'] as String?,
      tipo: json['tipo'] as String,
      descripcion: json['descripcion'] as String,
      pendiente: json['pendiente'] as bool,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      direccion: json['direccion'] as String,
      fechaHora: fecha,
      usuarioId: json['usuarioId'] as String,
      nombreUsuario: json['nombreUsuario'] as String?,
      correoUsuario: json['correoUsuario'] as String?,
      rolUsuario: json['rolUsuario'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final fechaSinDecimales = DateTime(
      fechaHora.year,
      fechaHora.month,
      fechaHora.day,
      fechaHora.hour,
      fechaHora.minute,
      fechaHora.second,
    );

    final Map<String, dynamic> data = {
      'tipo': tipo,
      'descripcion': descripcion,
      'pendiente': pendiente,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'fechaHora': fechaSinDecimales.toIso8601String(),
      'usuarioId': usuarioId,
    };

    if (id != null) data['id'] = id;
    if (nombreUsuario != null) data['nombreUsuario'] = nombreUsuario;
    if (correoUsuario != null) data['correoUsuario'] = correoUsuario;
    if (rolUsuario != null) data['rolUsuario'] = rolUsuario;

    return data;
  }
}
