class EnvConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    return isProduction
        ? 'http://pages-wt.gl.at.ply.gg:20954' // Backend expuesto con Playit
        : 'http://192.168.0.19:8080'; // Desarrollo local
  }
}
