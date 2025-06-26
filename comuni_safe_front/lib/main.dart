import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'views/admin/reportes_por_tipo_view.dart';
import 'package:comuni_safe_front/views/login/login_view.dart';
import 'package:comuni_safe_front/views/tutorial/TutorialView.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      await prefs.setBool('first_time', false);
    }
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ComuniSafe',
      home: FutureBuilder<bool>(
        future: _isFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return snapshot.data == true
              ? const TutorialView()
              : const LoginView();
        },
      ),
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

