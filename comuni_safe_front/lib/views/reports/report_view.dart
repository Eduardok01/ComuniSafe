import 'package:flutter/material.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  String selectedCategory = '';
  final TextEditingController descriptionController = TextEditingController();

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget buildCategoryButton({
    required String label,
    required String imagePath,
    required Color color,
    required String categoryKey,
  }) {
    final isSelected = selectedCategory == categoryKey;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(70),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      onPressed: () => selectCategory(categoryKey),
      child: Row(
        children: [
          Image.asset(imagePath, width: 36, height: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2DDBC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reporta un incidente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E3023),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            buildCategoryButton(
              label: 'Microtráfico',
              imagePath: 'assets/microtrafico.png',
              color: Colors.yellow.shade300,
              categoryKey: 'microtrafico',
            ),
            const SizedBox(height: 16),
            buildCategoryButton(
              label: 'Uso indebido de espacios',
              imagePath: 'assets/espacios.png',
              color: Colors.grey.shade400,
              categoryKey: 'uso_indebido',
            ),
            const SizedBox(height: 16),
            buildCategoryButton(
              label: 'Robo/Asalto',
              imagePath: 'assets/robo.png',
              color: Colors.red.shade200,
              categoryKey: 'robo',
            ),
            const SizedBox(height: 16),
            buildCategoryButton(
              label: 'Emergencia médica',
              imagePath: 'assets/ambulancia.png',
              color: Colors.white,
              categoryKey: 'medica',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descripción... (Opcional)',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reporte enviado')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reportar',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
