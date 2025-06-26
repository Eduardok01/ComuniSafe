import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/admin_user_list_view.dart';
import '../admin/reportes_por_tipo_view.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final List<Map<String, dynamic>> reportes = [
    {
      'icon': Icons.warning,
      'tipo': 'microtrafico',
      'titulo': 'Reportes por Microtráfico', // Edita este texto
    },
    {
      'icon': Icons.block,
      'tipo': 'uso_indebido',
      'titulo': 'Reportes por uso Indebido de espacios', // Edita este texto
    },
    {
      'icon': Icons.notifications,
      'tipo': 'robo',
      'titulo': 'Reportes por Robo/Asalto', // Edita este texto
    },
    {
      'icon': Icons.medical_services,
      'tipo': 'medica',
      'titulo': 'Reportes por Emergencia médica', // Edita este texto
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3CD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(child: Image.asset('assets/logo.png', height: 180)),
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
                      children: reportes.map((reporte) {
                        return _buildReportCard(
                          icon: reporte['icon'],
                          tituloVisible: reporte['titulo'],
                          tipoFirestore: reporte['tipo'],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, 'map'),
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
                          builder: (context) =>
                              AdminUserListView(token: token),
                        ),
                      );
                    } else {
                      _mostrarMensaje('No se pudo obtener el token');
                    }
                  } else {
                    _mostrarMensaje('Usuario no autenticado');
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

  Widget _buildReportCard({
    required IconData icon,
    required String tituloVisible,
    required String tipoFirestore,
  }) {
    return ReportCard(
      icon: icon,
      label: tituloVisible,
      count: 0,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportesPorTipoView(
              tipoReporte: tipoFirestore,
            ),
          ),
        );
      },
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
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
