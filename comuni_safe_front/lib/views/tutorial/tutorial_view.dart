import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TutorialView extends StatefulWidget {
  const TutorialView({super.key});

  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: 'Bienvenido a ComuniSafe',
      description: 'Tu aplicación para mantener segura a tu comunidad',
      icon: Icons.security,
      color: const Color(0xFFE2734B),
    ),
    TutorialPage(
      title: 'Reporta Incidentes',
      description: 'Informa sobre situaciones sospechosas o incidentes en tu área',
      icon: Icons.report_problem,
      color: Colors.orange,
    ),
    TutorialPage(
      title: 'Mapa Interactivo',
      description: 'Visualiza las zonas seguras y puntos de riesgo en tu comunidad',
      icon: Icons.map,
      color: Colors.green,
    ),
    TutorialPage(
      title: 'Contactos de Emergencia',
      description: 'Accede rápidamente a números de emergencia importantes',
      icon: Icons.emergency,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EE),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                const SizedBox(height: 20),
                if (_currentPage == _pages.length - 1)
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('first_time', false);

                      if (mounted) {
                        Navigator.pushReplacementNamed(context, 'login');
                      }
                    }
                    ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2734B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 100,
            color: page.color,
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length; i++) {
      indicators.add(
        Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? const Color(0xFFE2734B)
                : Colors.grey.withOpacity(0.4),
          ),
        ),
      );
    }
    return indicators;
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}