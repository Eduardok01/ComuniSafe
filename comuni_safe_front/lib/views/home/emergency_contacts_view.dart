import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsView extends StatefulWidget {
  const EmergencyContactsView({super.key});

  @override
  State<EmergencyContactsView> createState() => _EmergencyContactsViewState();
}

class _EmergencyContactsViewState extends State<EmergencyContactsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2734B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contactos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Presiona para llamar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            _buildContactTile('assets/samu.png', 'SAMU', '131'),
            _buildContactTile('assets/carabineros.png', 'Carabineros de Chile', '133'),
            _buildContactTile('assets/pdi.png', 'PDI', '134'),
            _buildContactTile('assets/temuco.png', 'Municipalidad Temuco', '1409'),
            _buildContactTile('assets/prevencion.png', 'Prevención del Delito', '6004000101'),
            _buildContactTile('assets/seguridad.png', 'Seguridad 24/7', '652200957'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(String assetPath, String name, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _makePhoneCall(number),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo realizar la llamada a $phoneNumber')),
      );
    }
  }
}
