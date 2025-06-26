import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/env_config.dart';
import '../../models/reporte.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  LatLng? userLocation;
  List<Marker> reportMarkers = [];

  ImageProvider getIconForTipo(String tipo) {
    switch (tipo) {
      case 'microtrafico':
        return const AssetImage('assets/microtrafico.png');
      case 'robo':
        return const AssetImage('assets/robo.png');
      case 'medica':
        return const AssetImage('assets/ambulancia.png');
      case 'uso_indebido':
        return const AssetImage('assets/espacios.png');
      default:
        return const AssetImage('assets/default.png');
    }
  }

  void _showPopupInfo(BuildContext context, Reporte reporte) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reporte: ${reporte.tipo}'),
        content: Text(reporte.descripcion.isNotEmpty
            ? reporte.descripcion
            : 'Sin descripción.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }


  @override
  @override
  void initState() {
    super.initState();
    _getUserLocation().then((_) {
      fetchReportesActivos();
    });
  }


  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> fetchReportesActivos() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/api/reportes/activos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Marker> nuevos = [];

        for (var item in data) {
          final reporte = Reporte.fromJson(item);
          final icon = getIconForTipo(reporte.tipo);

          nuevos.add(
            Marker(
              width: 48,
              height: 48,
              point: LatLng(reporte.latitud, reporte.longitud),
              child: GestureDetector(
                onTap: () => _showPopupInfo(context, reporte),
                child: Image(image: icon),
              ),
            ),
          );
        }

        if (mounted) {
          setState(() {
            reportMarkers = nuevos;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar reportes: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Mapa'),
        backgroundColor: const Color(0xFFE2734B),
      ),
      body: userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.comunisafe',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  ...reportMarkers,
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2734B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'report');
              },
              child: const Text(
                'Reportar',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
