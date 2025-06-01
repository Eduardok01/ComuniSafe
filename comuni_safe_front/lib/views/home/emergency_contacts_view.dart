import 'package:flutter/material.dart';

class EmergencyContactsView extends StatelessWidget {
  const EmergencyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2C0A5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Contactos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Center(child: Text('Presiona para llamar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,))),
            const SizedBox(height: 30),
            _buildContactTile(context, 'assets/samu.png', 'SAMU', '131'),
            _buildContactTile(context, 'assets/carabineros.png', 'Carabineros de Chile', '133'),
            _buildContactTile(context, 'assets/pdi.png', 'PDI', '134'),
            _buildContactTile(context, 'assets/temuco.png', 'Municipalidad Temuco', '1409'),
            _buildContactTile(context, 'assets/prevencion.png', 'Prevención del Delito', '600 4000 101'),
            _buildContactTile(context, 'assets/seguridad.png', 'Seguridad 24/7', '652 200 957'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, String assetPath, String name, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Image.asset(assetPath, height: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
