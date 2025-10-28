import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

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
      });
      await _addToHistory(city);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not fetch weather')));
    }
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
              // optional: open favorites panel
              showModalBottomSheet(
                context: context,
                builder: (_) => _buildFavoritesSheet(),
              );
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

            const SizedBox(height: 12),

            // Current weather display (reuse your existing UI; show temperature etc.)
            if (_weather != null) ...[
              Text('${_weather!.main.temp.round()}°C', style: Theme.of(context).textTheme.headlineLarge),
              Text(_weather!.weather.first.description.toUpperCase()),
            ] else
              const SizedBox(),

            const SizedBox(height: 12),

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
