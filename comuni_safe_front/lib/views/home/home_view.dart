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
            Image.asset(
              'assets/logo.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            _buildImageButton(
              'assets/contactos-logo.png',
              'Contactos de emergencia',
                  () {
                Navigator.pushNamed(context, 'emergency_contacts');
              },
            ),

            _buildImageButton(
              'assets/llamada-carabineros.png',
              'Llamada rápida Carabineros',
                  () {
                // lógica
              },
            ),

            _buildImageButton(
              'assets/llamada-ambulancia.png',
              'Llamada rápida Ambulancia',
                  () {
                // lógica
              },
            ),

            _buildImageButton(
              'assets/mapa-logo.png',
              'Ver el mapa',
                  () {
                // lógica
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'login', (route) => false);
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //Navigator.pushNamed(context, 'profile');
                  },
                  child: Row(
                    children: const [
                      Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ver perfil',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageButton(
      String assetPath, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE2734B),
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0, //
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
