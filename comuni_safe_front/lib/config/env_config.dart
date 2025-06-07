class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction
        ? 'https://api.comunisafe.app' // producción
        //: 'http://http://10.0.2.2:8080'; // IP Para emular el teléfono
        : 'http://Aca va la IP de tu PC:8080';      // IP para teléfono físico
  }
}
