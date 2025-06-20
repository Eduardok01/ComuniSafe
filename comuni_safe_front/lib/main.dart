import 'package:comuni_safe_front/views/login/login_view.dart';
import 'package:comuni_safe_front/views/tutorial/tutorial_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'views/admin/reporte_filtrado_view.dart';
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
        'reportes_microtrafico': (context) => const ReporteFiltradoView(tipo: 'microtrafico'),
        'reportes_uso_indebido': (context) => const ReporteFiltradoView(tipo: 'uso_indebido'),
        'reportes_robo_asalto': (context) => const ReporteFiltradoView(tipo: 'robo_asalto'),
        'reportes_emergencia_medica': (context) => const ReporteFiltradoView(tipo: 'emergencia_medica'),
      },
    );
  }

}
