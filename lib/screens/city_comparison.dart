import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class CityComparison extends StatefulWidget {
  const CityComparison({super.key});

  @override
  State<CityComparison> createState() => _CityComparisonState();
}

class _CityComparisonState extends State<CityComparison> {
  final WeatherService _service = WeatherService();
  final TextEditingController _aCtrl = TextEditingController();
  final TextEditingController _bCtrl = TextEditingController();

  WeatherModel? _aWeather;
  WeatherModel? _bWeather;
  bool _loading = false;

  List<String> _aSuggestions = [];
  List<String> _bSuggestions = [];

  Future<void> _compare() async {
    final a = _aCtrl.text.trim();
    final b = _bCtrl.text.trim();
    if (a.isEmpty || b.isEmpty) return;
    setState(() { _loading = true; _aWeather = null; _bWeather = null; });
    final res = await Future.wait([_service.getWeatherByCity(a), _service.getWeatherByCity(b)]);
    setState(() {
      _aWeather = res[0];
      _bWeather = res[1];
      _loading = false;
    });
  }

  Future<void> _updateASuggestions(String q) async {
    if (q.trim().isEmpty) { setState(() => _aSuggestions = []); return; }
    final s = await _service.getCitySuggestions(q);
    setState(() => _aSuggestions = s);
  }

  Future<void> _updateBSuggestions(String q) async {
    if (q.trim().isEmpty) { setState(() => _bSuggestions = []); return; }
    final s = await _service.getCitySuggestions(q);
    setState(() => _bSuggestions = s);
  }

  Widget _cardFor(WeatherModel? w, String label) {
    if (w == null) {
      return Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('No data for $label')));
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${w.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${w.weather.first.description.toUpperCase()}'),
          const SizedBox(height: 10),
          Text('Temp: ${w.main.temp.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text('Min/Max: ${w.main.tempMin.round()}° / ${w.main.tempMax.round()}°'),
          const SizedBox(height: 6),
          Wrap(spacing: 12, children: [
            Text('Humidity: ${w.main.humidity}%'),
            Text('Wind: ${w.wind.speed} m/s'),
            Text('Pressure: ${w.main.pressure} hPa'),
          ]),
          const SizedBox(height: 8),
          Text('Coords: ${w.coord.lat.toStringAsFixed(2)}, ${w.coord.lon.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diff = (_aWeather != null && _bWeather != null) ? (_aWeather!.main.temp - _bWeather!.main.temp).abs() : null;
    return Scaffold(
      appBar: AppBar(title: const Text('City Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // inputs + suggestions
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _aCtrl,
                    decoration: const InputDecoration(labelText: 'City A'),
                    onChanged: (v) => _updateASuggestions(v),
                    onSubmitted: (_) => _updateASuggestions(_aCtrl.text),
                  ),
                  if (_aSuggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _aSuggestions.map((s) => ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          onPressed: () { _aCtrl.text = s; setState(() => _aSuggestions = []); },
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _bCtrl,
                    decoration: const InputDecoration(labelText: 'City B'),
                    onChanged: (v) => _updateBSuggestions(v),
                    onSubmitted: (_) => _updateBSuggestions(_bCtrl.text),
                  ),
                  if (_bSuggestions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _bSuggestions.map((s) => ActionChip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          onPressed: () { _bCtrl.text = s; setState(() => _bSuggestions = []); },
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _loading ? null : _compare, child: _loading ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Text('Compare')),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(children: [Expanded(child: _cardFor(_aWeather, 'A')), const SizedBox(width: 12), Expanded(child: _cardFor(_bWeather, 'B'))])
                  : ListView(children: [_cardFor(_aWeather, 'A'), _cardFor(_bWeather, 'B')]);
            }),
          ),
          if (diff != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Temperature difference: ${diff.toStringAsFixed(1)}°C', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }
}