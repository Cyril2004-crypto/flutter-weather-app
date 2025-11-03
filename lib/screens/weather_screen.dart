import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/daily_summary.dart'; // <--- use DailySummary

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
  List<DailySummary> _daily = [];
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
        _daily = []; // clear previous aggregated forecast
      });
      await _addToHistory(city);

      // fetch 5-day aggregated forecast (uses /data/2.5/forecast)
      try {
        final agg = await _service.get5DayAggregated(city);
        setState(() => _daily = agg);
      } catch (e) {
        // ignore forecast errors
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not fetch weather')));
    }
  }

  String _formatDateFromDate(DateTime d) {
    return '${d.month}/${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // smaller bottomPad to avoid overflow; keeps keyboard inset if present
    // use only viewInsets bottom plus a small margin (avoid double-counting safe area)
    final double bottomPad = MediaQuery.of(context).viewInsets.bottom + 8;

    // adaptively tighten some sizes on short windows
    final double availHeight = MediaQuery.of(context).size.height;
    final bool compact = availHeight < 700;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: compact ? 44 : 48, // slightly smaller on compact
        title: Text('Welcome, ${widget.username}', style: TextStyle(fontSize: compact ? 16 : 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 20),
            onPressed: () => showModalBottomSheet(context: context, builder: (_) => _buildFavoritesSheet()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () async => await widget.onLogout(),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens, size: 20),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        // ListView handles available viewport better and prevents bottom overflow
        child: ListView(
          padding: EdgeInsets.fromLTRB(8, 6, 8, bottomPad),
          children: [
            // SEARCH ROW (more compact)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: compact ? 28 : 32,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_city, size: 16),
                        hintText: 'City name',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (v) => _searchWeather(v.trim()),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: () {
                    final city = _searchController.text.trim();
                    if (city.isNotEmpty) _searchWeather(city);
                  },
                ),
                IconButton(
                  icon: Icon(_favorites.contains(_searchController.text.trim()) ? Icons.star : Icons.star_border, size: 20),
                  onPressed: () {
                    final city = _searchController.text.trim();
                    if (city.isNotEmpty) _toggleFavorite(city);
                  },
                ),
              ],
            ),

            const SizedBox(height: 6),

            // CURRENT WEATHER (compact)
            if (_weather != null) ...[
              Text('${_weather!.main.temp.round()}°C',
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: compact ? 20 : 24)),
              const SizedBox(height: 2),
              Text(_weather!.weather.first.description.toUpperCase(), style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),

              // compact stats grid (3 columns) — denser
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 6,
                mainAxisSpacing: 0, // tighten rows
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: compact ? 4.5 : 4.2, // increase ratio to reduce cell height
                children: [
                  _smallStat(Icons.thermostat, 'Min/Max', '${_weather!.main.tempMin.round()}° / ${_weather!.main.tempMax.round()}°'),
                  _smallStat(Icons.water_drop, 'Humidity', '${_weather!.main.humidity}%'),
                  _smallStat(Icons.compress, 'Pressure', '${_weather!.main.pressure} hPa'),
                  _smallStat(Icons.air, 'Wind', '${_weather!.wind.speed} m/s'),
                  _smallStat(Icons.cloud, 'Clouds', '${_weather!.clouds.all}%'),
                  _smallStat(Icons.location_on, 'Coords', '${_weather!.coord.lat.toStringAsFixed(2)}, ${_weather!.coord.lon.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // FORECAST — collapsed summary (tap to expand)
            if (_daily.isNotEmpty)
              ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('5-day Forecast', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${_daily.length} days', style: theme.textTheme.bodySmall),
                  ],
                ),
                initiallyExpanded: false,
                dense: true,
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: _daily.map((day) {
                  final iconUrl = day.icon.isNotEmpty ? 'https://openweathermap.org/img/wn/${day.icon}@2x.png' : null;
                  return ListTile(
                    leading: iconUrl != null
                        ? Image.network(iconUrl, width: compact ? 28 : 36, height: compact ? 28 : 36, errorBuilder: (_, __, ___) => const Icon(Icons.cloud))
                        : const Icon(Icons.cloud),
                    title: Text(_formatDateFromDate(day.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${day.avgTemp.round()}° — ${day.description}'),
                    dense: true,
                    visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
                  );
                }).toList(),
              ),

            // COLLAPSIBLE LISTS — keep dense and collapsed
            const SizedBox(height: 6),
            ExpansionTile(
              title: Text('Search History (${_history.length})'),
              initiallyExpanded: false,
              dense: true,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                Wrap(spacing: 6, runSpacing: 6, children: _history.map((c) => ActionChip(label: Text(c), onPressed: () { _searchController.text = c; _searchWeather(c); })).toList()),
              ],
            ),
            ExpansionTile(
              title: Text('Favorites (${_favorites.length})'),
              initiallyExpanded: false,
              dense: true,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              children: [
                Wrap(spacing: 6, runSpacing: 6, children: _favorites.map((c) => InputChip(
                  label: Text(c, style: const TextStyle(fontSize: 12)),
                  onPressed: () { _searchController.text = c; _searchWeather(c); },
                  onDeleted: () async { setState(() => _favorites.remove(c)); await _saveFavorites(); },
                )).toList()),
              ],
            ),

            // minimal bottom spacing (removed large spacer)
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _smallStat(IconData icon, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 1),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 1),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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
