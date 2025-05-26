import 'package:flutter/material.dart';
import 'package:comuni_safe_front/views/login/login_view.dart';
import 'package:comuni_safe_front/views/register/register_view.dart';
import 'package:comuni_safe_front/views/home/home_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  'login': (BuildContext context) => const LoginView(),
  'register': (BuildContext context) => const RegisterView(),
  'home': (context) => const HomeView(),
};
