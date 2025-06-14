import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/admin_user_list_view.dart';

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
              Center(
                child: Image.asset('assets/logo.png', height: 180),
              ),

              const SizedBox(height: 0),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEEED9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
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

              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, 'map');
                },
                icon: const Icon(Icons.map),
                label: const Text('Ver el mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD26033),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final token = await user.getIdToken();
                    if (token != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserListView(token: token),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo obtener el token')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario no autenticado')),
                    );
                  }
                },
                icon: const Icon(Icons.people),
                label: const Text('Ver lista de usuarios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD26033),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFooterButton(
                    icon: Icons.logout,
                    label: 'Cerrar Sesión',
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, 'login');
                    },
                  ),
                  _buildFooterButton(
                    icon: Icons.person,
                    label: 'Ver perfil',
                    onTap: () {
                      Navigator.pushNamed(context, 'profile');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
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
