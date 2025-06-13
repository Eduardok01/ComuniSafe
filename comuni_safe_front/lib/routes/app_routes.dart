import 'package:flutter/material.dart';
import 'package:comuni_safe_front/views/login/login_view.dart';
import 'package:comuni_safe_front/views/register/register_view.dart';
import 'package:comuni_safe_front/views/home/home_view.dart';
import 'package:comuni_safe_front/views/home/emergency_contacts_view.dart';
import 'package:comuni_safe_front/views/profile/profile_view.dart';  // <-- Importa ProfileView
import '../views/home/admin_home_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  'login': (BuildContext context) => const LoginView(),
  'register': (BuildContext context) => const RegisterView(),
  'home': (context) => const HomeView(),
  'emergency_contacts': (context) => const EmergencyContactsView(),
  'admin_home': (context) => const AdminHomeView(),
  'profile': (context) => const ProfileView(),  // <-- Agrega la ruta para ProfileView
};