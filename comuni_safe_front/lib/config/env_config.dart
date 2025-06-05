class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction
        ? 'https://api.comunisafe.app' // producción
        : 'http://"Aca va la IP del PC":8080';      // desarrollo (emulador Android)
  }
}
