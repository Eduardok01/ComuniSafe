class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction
        ? 'https://api.comunisafe.app' // producción
        : 'http://10.0.2.2:8080';      // desarrollo (emulador Android)
  }
}
