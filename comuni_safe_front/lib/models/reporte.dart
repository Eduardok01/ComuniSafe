class Reporte {
  String tipo;
  String descripcion;
  bool pendiente;
  double latitud;
  double longitud;
  String direccion;
  DateTime fechaHora;
  String usuarioId;

  Reporte({
    required this.tipo,
    required this.descripcion,
    required this.pendiente,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.fechaHora,
    required this.usuarioId,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
    tipo: json['tipo'] as String,
    descripcion: json['descripcion'] as String,
    pendiente: json['pendiente'] as bool,
    latitud: (json['latitud'] as num).toDouble(),
    longitud: (json['longitud'] as num).toDouble(),
    direccion: json['direccion'] as String,
    fechaHora: DateTime.parse(json['fechaHora'] as String),
    usuarioId: json['usuarioId'] as String,
  );

  Map<String, dynamic> toJson() {
    final fechaSinDecimales = DateTime(
      fechaHora.year,
      fechaHora.month,
      fechaHora.day,
      fechaHora.hour,
      fechaHora.minute,
      fechaHora.second,
    );

    return {
      'tipo': tipo,
      'descripcion': descripcion,
      'pendiente': pendiente,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'fechaHora': fechaSinDecimales.toIso8601String(),
      'usuarioId': usuarioId,
    };
  }
}
