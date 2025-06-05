import 'package:comuni_safe_front/views/home/home_view.dart';
import 'package:comuni_safe_front/views/login/login_view.dart';
import 'package:comuni_safe_front/views/profile/profile_view.dart';
import 'package:comuni_safe_front/views/register/register_view.dart'; // Importa la vista de registro
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
        'login': (context) => const LoginView(),
        'home': (context) => const HomeView(),
        'profile': (context) => const ProfileView(),
        'register': (context) => const RegisterView(), // Agrega la ruta 'register'
      },
    );
  }
}
