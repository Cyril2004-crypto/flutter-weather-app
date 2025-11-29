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

  final String _owmKey = '085e22f212b11b6c58a6fa2043817cc5'; // or store in WeatherService

  double _overlayOpacity = 0.6;
  bool _showPrecip = true;
  bool _showClouds = false;

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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: _markers.isNotEmpty ? _markers.first.point : LatLng(0, 0), zoom: 4),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              if (_showPrecip)
                Opacity(
                  opacity: _overlayOpacity,
                  child: TileLayer(
                    urlTemplate: 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$_owmKey',
                    tileProvider: NetworkTileProvider(),
                  ),
                ),
              if (_showClouds)
                Opacity(
                  opacity: _overlayOpacity,
                  child: TileLayer(
                    urlTemplate: 'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$_owmKey',
                    tileProvider: NetworkTileProvider(),
                  ),
                ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            right: 12,
            top: 80,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () => setState(() => _showPrecip = !_showPrecip),
                  child: Icon(_showPrecip ? Icons.opacity : Icons.opacity_outlined),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => setState(() => _showClouds = !_showClouds),
                  child: Icon(_showClouds ? Icons.cloud : Icons.cloud_outlined),
                ),
                const SizedBox(height: 8),
                // opacity slider popup
                FloatingActionButton(
                  mini: true,
                  onPressed: () => showModalBottomSheet(context: context, builder: (_) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Overlay opacity'),
                        Slider(value: _overlayOpacity, onChanged: (v) => setState(() => _overlayOpacity = v), min: 0.0, max: 1.0),
                      ]),
                    );
                  }),
                  child: const Icon(Icons.tune),
                ),
              ],
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