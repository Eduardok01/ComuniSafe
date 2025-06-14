import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'views/admin/reporte_filtrado_view.dart';

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
        'reportes_microtrafico': (context) => const ReporteFiltradoView(tipo: 'microtrafico'),
        'reportes_uso_indebido': (context) => const ReporteFiltradoView(tipo: 'uso_indebido'),
        'reportes_robo_asalto': (context) => const ReporteFiltradoView(tipo: 'robo_asalto'),
        'reportes_emergencia_medica': (context) => const ReporteFiltradoView(tipo: 'emergencia_medica'),
      },
    );
  }
}
