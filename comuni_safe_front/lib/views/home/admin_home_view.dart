import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4E3CD),
    body: SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
    children: [
    Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Image.asset('assets/logo.png', height: 150),
    const SizedBox(width: 12),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
    Text(
    'Comuni\nSafe',
    style: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFFD26033),
    height: 1.2,
    ),
    ),
    Text(
    'Admin',
    style: TextStyle(
    color: Colors.black87,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    ),
    )
    ],
    ),
    ],
    ),
    const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFEEED9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.description, size: 40),
            const SizedBox(height: 8),
            const Text(
              '3 reportes en total.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ReportCard(
                  icon: Icons.warning,
                  label: 'reporte microtráfico',
                  count: 1,
                ),
                ReportCard(
                  icon: Icons.block,
                  label: 'reporte uso indebido espacios',
                  count: 1,
                ),
                ReportCard(
                  icon: Icons.notifications,
                  label: 'reporte robo/asalto',
                  count: 1,
                ),
                ReportCard(
                  icon: Icons.medical_services,
                  label: 'reporte emergencia médica',
                  count: 0,
                ),
              ],
            )
          ],
        ),
      ),

      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, 'map');
        },
        icon: const Icon(Icons.map),
        label: const Text('Ver el mapa'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD26033),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      const Spacer(),

      // Footer
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar\nSesión'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, 'profile');
            },
            icon: const Icon(Icons.person),
            label: const Text('Ver\nperfil'),
          ),
        ],
      )
    ],
    ),
    ),
    ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const ReportCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9DFA4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}