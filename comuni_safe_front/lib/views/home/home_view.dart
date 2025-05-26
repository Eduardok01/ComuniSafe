import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E6D0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 200),
            const SizedBox(height: 24),
            _buildButton(Icons.phone, 'Contactos de emergencia'),
            _buildButton(Icons.shield, 'Llamada rápida Carabineros'),
            _buildButton(Icons.local_hospital, 'Llamada rápida Ambulancia'),
            _buildButton(Icons.map, 'Ver el mapa'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                  },
                  child: const Column(
                    children: [
                      Icon(Icons.logout),
                      Text('Cerrar Sesión', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.person),
                    Text('Ver perfil', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2734B),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {},
        icon: Icon(icon, color: Colors.black),
        label: Text(label, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
