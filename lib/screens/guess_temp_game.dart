import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';

class GuessTempGame extends StatefulWidget {
  const GuessTempGame({super.key});

  @override
  State<GuessTempGame> createState() => _GuessTempGameState();
}

class _GuessTempGameState extends State<GuessTempGame> {
  final WeatherService _service = WeatherService();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _guessCtrl = TextEditingController();
  WeatherModel? _weather;
  String? _message;
  int _lastScore = 0;
  int _highScore = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _highScore = prefs.getInt('guess_temp_highscore') ?? 0);
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('guess_temp_highscore', score);
    setState(() => _highScore = score);
  }

  Future<void> _fetchWeather(String city) async {
    if (city.isEmpty) return;
    setState(() {
      _loading = true;
      _message = null;
      _weather = null;
    });
    final res = await _service.getWeatherByCity(city);
    setState(() {
      _loading = false;
      if (res == null) {
        _message = 'Could not fetch weather for "$city".';
      } else {
        _weather = res;
        _message = 'Fetched weather for $city — submit your guess!';
      }
    });
  }

  void _submitGuess() {
    if (_weather == null) {
      setState(() => _message = 'Fetch a city first.');
      return;
    }
    final guess = double.tryParse(_guessCtrl.text);
    if (guess == null) {
      setState(() => _message = 'Enter a valid numeric guess.');
      return;
    }
    final real = _weather!.main.temp;
    final diff = (real - guess).abs();
    final score = (100 - diff.round()).clamp(0, 100);
    setState(() {
      _lastScore = score;
      _message = 'Real: ${real.toStringAsFixed(1)}°C — diff ${diff.toStringAsFixed(1)}° → +$score pts';
    });
    if (score > _highScore) _saveHighScore(score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guess the Temperature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guess the current temperature of any city. Closer = more points.', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(labelText: 'City', hintText: 'e.g. London'),
                  onSubmitted: (v) => _fetchWeather(v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _loading ? null : () => _fetchWeather(_cityCtrl.text.trim()),
                child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Fetch'),
              ),
            ]),
            const SizedBox(height: 12),
            if (_weather != null) ...[
              Text('Weather: ${_weather!.weather.first.description.toUpperCase()}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text('Location: ${_weather!.name}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _guessCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Your guess (°C)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submitGuess, child: const Text('Submit')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _guessCtrl.text = _weather!.main.temp.toStringAsFixed(1);
                      _submitGuess();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Auto'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (_message != null) Text(_message!, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last: $_lastScore', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('High: $_highScore', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Center(child: TextButton(onPressed: () async { await _saveHighScore(0); setState(() => _lastScore = 0); }, child: const Text('Reset high score'))),
          ],
        ),
      ),
    );
  }
}