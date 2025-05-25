import 'package:flutter/material.dart';
import 'package:comuni_safe_front/routes/app_routes.dart';

void main() {
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
      routes: appRoutes,
    );
  }
}
