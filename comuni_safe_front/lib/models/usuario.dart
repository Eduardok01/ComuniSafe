class Usuario {
  final String uid;
  final String name;
  final String correo;
  final String phone;
  final String rol;

  Usuario({
    required this.uid,
    required this.name,
    required this.correo,
    required this.phone,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      correo: json['correo'] ?? '',
      phone: json['phone'] ?? '',
      rol: json['rol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'correo': correo,
      'phone': phone,
      'rol': rol,
    };
  }
}
