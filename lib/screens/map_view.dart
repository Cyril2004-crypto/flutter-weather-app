import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});
  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  final WeatherService _service = WeatherService();
  List<Marker> _markers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() {
      _loading = true;
      _markers = [];
    });
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    final jobs = favorites.map((c) async {
      final w = await _service.getWeatherByCity(c);
      if (w != null) {
        final lat = w.coord.lat;
        final lon = w.coord.lon;
        _markers.add(Marker(
          width: 48,
          height: 48,
          point: LatLng(lat, lon),
          builder: (ctx) => GestureDetector(
            onTap: () => _showInfo(w),
            child: const Icon(Icons.location_on, color: Colors.blueAccent, size: 28),
          ),
        ));
      }
    }).toList();

    await Future.wait(jobs);
    setState(() {
      _loading = false;
    });
  }

  void _showInfo(WeatherModel w) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${w.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${w.weather.first.description.toUpperCase()}'),
            const SizedBox(height: 6),
            Text('Temp: ${w.main.temp.toStringAsFixed(1)}°C'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ]),
        );
      },
    );
  }

  Future<void> _centerOnUser() async {
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _mapController.move(LatLng(pos.latitude, pos.longitude), 10);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get location')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _markers.isNotEmpty ? _markers.first.point : LatLng(0, 0),
                zoom: 4,
                onTap: (_, __) {}, // no-op; marker taps handle showing info
              ),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(50)),
                    markers: _markers,
                    showPolygon: false,
                    // omitted popupOptions (requires popupState). Marker tap opens bottom sheet instead.
                    builder: (context, markers) {
                      return Container(
                        alignment: Alignment.center,
                        decoration:
                            BoxDecoration(color: Colors.blue.withOpacity(0.8), shape: BoxShape.circle),
                        child: Text('${markers.length}', style: const TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'loc',
            mini: true,
            onPressed: _centerOnUser,
            tooltip: 'Center on my location',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'refresh',
            mini: true,
            onPressed: _loadMarkers,
            tooltip: 'Refresh markers',
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}