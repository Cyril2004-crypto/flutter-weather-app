import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/daily_summary.dart'; // <--- changed import

class WeatherService {
  static const String _apiKey = '085e22f212b11b6c58a6fa2043817cc5';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Event-driven API call triggered by search button
  Future<WeatherModel?> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse('$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }

  // Alternative method using coordinates
  Future<WeatherModel?> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return WeatherModel.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }

  Future<List<DailySummary>> get5DayAggregated(String cityName) async {
    try {
      final url = Uri.parse('$_baseUrl/forecast?q=$cityName&appid=$_apiKey&units=metric');
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        print('Forecast error: ${resp.statusCode} -- ${resp.body}');
        return [];
      }
      final Map<String, dynamic> jsonData = json.decode(resp.body);
      final List<dynamic> list = jsonData['list'] ?? [];

      // group entries by local date
      final Map<String, List<Map<String, dynamic>>> groups = {};
      for (final e in list.cast<Map<String, dynamic>>()) {
        final dtTxt = e['dt_txt'] as String? ?? '';
        final dateKey = dtTxt.split(' ').first; // 'YYYY-MM-DD'
        groups.putIfAbsent(dateKey, () => []).add(e);
      }

      final summaries = <DailySummary>[];
      final keys = groups.keys.toList()..sort();
      // take up to 5 days
      for (final key in keys.take(5)) {
        final items = groups[key]!;
        double minT = double.infinity;
        double maxT = -double.infinity;
        double sumT = 0;
        double sumWind = 0;
        int sumHum = 0;
        int count = 0;
        final Map<String, int> descCount = {};
        String pickIcon = '';

        for (final it in items) {
          final main = it['main'] as Map<String, dynamic>? ?? {};
          final weatherList = (it['weather'] as List<dynamic>?) ?? [];
          final double temp = (main['temp'] as num?)?.toDouble() ?? 0.0;
          final int hum = (main['humidity'] as num?)?.toInt() ?? 0;
          final wind = (it['wind'] as Map<String, dynamic>?) ?? {};
          final double w = (wind['speed'] as num?)?.toDouble() ?? 0.0;

          minT = temp < minT ? temp : minT;
          maxT = temp > maxT ? temp : maxT;
          sumT += temp;
          sumWind += w;
          sumHum += hum;
          count++;

          if (weatherList.isNotEmpty) {
            final w0 = weatherList.first as Map<String, dynamic>;
            final desc = (w0['description'] ?? '').toString();
            final icon = (w0['icon'] ?? '').toString();
            descCount[desc] = (descCount[desc] ?? 0) + 1;
            if (pickIcon.isEmpty) pickIcon = icon;
          }
        }

        if (count == 0) continue;
        final avgT = sumT / count;
        final avgW = sumWind / count;
        final avgH = (sumHum / count).round();

        // pick most frequent description
        String bestDesc = '';
        int bestCount = 0;
        descCount.forEach((k, v) {
          if (v > bestCount) {
            bestCount = v;
            bestDesc = k;
          }
        });

        final dateParts = key.split('-');
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );

        summaries.add(DailySummary(
          date: date,
          minTemp: minT == double.infinity ? 0.0 : minT,
          maxTemp: maxT == -double.infinity ? 0.0 : maxT,
          avgTemp: avgT,
          avgWind: avgW,
          avgHumidity: avgH,
          description: bestDesc,
          icon: pickIcon,
        ));
      }

      return summaries;
    } catch (e, st) {
      print('Error aggregating forecast: $e\n$st');
      return [];
    }
  }

  /// Return a short list of "Name, State, Country" suggestions for [query].
  /// Uses OpenWeatherMap direct geocoding endpoint.
  Future<List<String>> getCitySuggestions(String query, {int limit = 6}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final url = 'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(q)}&limit=$limit&appid=$_apiKey';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      final List<String> out = [];
      for (final e in data) {
        final name = (e['name'] ?? '').toString();
        final state = (e['state'] ?? '').toString();
        final country = (e['country'] ?? '').toString();
        final parts = [name];
        if (state.isNotEmpty) parts.add(state);
        if (country.isNotEmpty) parts.add(country);
        out.add(parts.join(', '));
      }
      return out;
    } catch (_) {
      return [];
    }
  }
}
