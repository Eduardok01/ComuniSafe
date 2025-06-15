import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'views/admin/reportes_por_tipo_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ComuniSafe',
      initialRoute: 'login',
      routes: {
        ...appRoutes,
        'reportes_microtrafico': (context) =>
        const ReportesPorTipoView(tipoReporte: 'microtrafico'),
        'reportes_uso_indebido': (context) =>
        const ReportesPorTipoView(tipoReporte: 'uso_indebido'),
        'reportes_robo_asalto': (context) =>
        const ReportesPorTipoView(tipoReporte: 'robo'),
        'reportes_emergencia_medica': (context) =>
        const ReportesPorTipoView(tipoReporte: 'medica'),
      },
    );
  }
}
