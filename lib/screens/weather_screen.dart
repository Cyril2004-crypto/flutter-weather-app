import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart'; // new import

class WeatherScreen extends StatefulWidget {
  final String username;
  final Future<void> Function() onLogout;
  final VoidCallback toggleTheme;

  const WeatherScreen({
    super.key,
    required this.username,
    required this.onLogout,
    required this.toggleTheme,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _searchController = TextEditingController();
  WeatherModel? _weather;
  List<DailyForecast> _forecast = [];
  List<String> _favorites = [];
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLists();
  }

  Future<void> _loadSavedLists() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
      _history = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _history);
  }

  Future<void> _toggleFavorite(String city) async {
    setState(() {
      if (_favorites.contains(city)) {
        _favorites.remove(city);
      } else {
        _favorites.add(city);
      }
    });
    await _saveFavorites();
  }

  Future<void> _addToHistory(String city) async {
    setState(() {
      _history.remove(city);
      _history.insert(0, city);
      if (_history.length > 10) _history = _history.sublist(0, 10);
    });
    await _saveHistory();
  }

  Future<void> _searchWeather(String city) async {
    final result = await _service.getWeatherByCity(city);
    if (result != null) {
      setState(() {
        _weather = result;
        _forecast = [];
      });
      await _addToHistory(city);

      // fetch forecast by coordinates if available
      try {
        final lat = _weather!.coord.lat;
        final lon = _weather!.coord.lon;
        final fc = await _service.get10DayForecast(lat, lon);
        setState(() => _forecast = fc);
      } catch (e) {
        // ignore missing coord
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not fetch weather')));
    }
  }

  String _formatDate(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              showModalBottomSheet(context: context, builder: (_) => _buildFavoritesSheet());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.onLogout();
            },
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city),
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (v) => _searchWeather(v.trim()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final city = _searchController.text.trim();
                    if (city.isNotEmpty) _searchWeather(city);
                  },
                ),
                IconButton(
                  icon: Icon(_favorites.contains(_searchController.text.trim()) ? Icons.star : Icons.star_border),
                  onPressed: () {
                    final city = _searchController.text.trim();
                    if (city.isNotEmpty) _toggleFavorite(city);
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Current weather display and details
            if (_weather != null) ...[
              Text('${_weather!.main.temp.round()}°C', style: Theme.of(context).textTheme.displaySmall),
              Text(_weather!.weather.first.description.toUpperCase(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(Icons.thermostat, 'Min/Max', '${_weather!.main.tempMin.round()}°C / ${_weather!.main.tempMax.round()}°C'),
                      _statItem(Icons.water_drop, 'Humidity', '${_weather!.main.humidity}%'),
                      _statItem(Icons.compress, 'Pressure', '${_weather!.main.pressure} hPa'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(Icons.air, 'Wind', '${_weather!.wind.speed} m/s'),
                      _statItem(Icons.cloud, 'Clouds', '${_weather!.clouds.all}%'),
                      _statItem(Icons.location_on, 'Coords', '${_weather!.coord.lat.toStringAsFixed(2)}, ${_weather!.coord.lon.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
            ] else
              const SizedBox(),

            const SizedBox(height: 14),

            // Forecast horizontal list
            if (_forecast.isNotEmpty) ...[
              Align(alignment: Alignment.centerLeft, child: const Text('10-day Forecast', style: TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _forecast.length,
                  itemBuilder: (context, i) {
                    final day = _forecast[i];
                    final iconUrl = 'https://openweathermap.org/img/wn/${day.icon}@2x.png';
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_formatDate(day.dt), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Image.network(iconUrl, width: 48, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.cloud)),
                              const SizedBox(height: 4),
                              Text('${day.tempDay.round()}°C'),
                              const SizedBox(height: 4),
                              Text(day.description, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Search history chips
            if (_history.isNotEmpty) Align(alignment: Alignment.centerLeft, child: const Text('Search History')),
            Wrap(
              spacing: 8,
              children: _history.map((c) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = c;
                    _searchWeather(c);
                  },
                  onLongPress: () async {
                    setState(() {
                      _history.remove(c);
                    });
                    await _saveHistory();
                  },
                  child: Chip(label: Text(c)),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Favorites list
            if (_favorites.isNotEmpty) Align(alignment: Alignment.centerLeft, child: const Text('Favorites')),
            Wrap(
              spacing: 8,
              children: _favorites.map((c) {
                return InputChip(
                  label: Text(c),
                  selected: false,
                  onPressed: () {
                    _searchController.text = c;
                    _searchWeather(c);
                  },
                  onDeleted: () async {
                    setState(() {
                      _favorites.remove(c);
                    });
                    await _saveFavorites();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildFavoritesSheet() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: _favorites
          .map((c) => ListTile(
                title: Text(c),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    setState(() => _favorites.remove(c));
                    await _saveFavorites();
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  Navigator.pop(context);
                  _searchController.text = c;
                  _searchWeather(c);
                },
              ))
          .toList(),
    );
  }
}
