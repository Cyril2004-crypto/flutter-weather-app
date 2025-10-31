import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart'; // new import

class WeatherService {
  static const String _apiKey = '085e22f212b11b6c58a6fa2043817cc5';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _oneCallBase = 'https://api.openweathermap.org/data/2.5/onecall';

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

  // New: fetch daily forecast (onecall) and return up to 10 days
  Future<List<DailyForecast>> get10DayForecast(double lat, double lon) async {
    try {
      final url = Uri.parse('$_oneCallBase?lat=$lat&lon=$lon&exclude=current,minutely,hourly,alerts&units=metric&appid=$_apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> daily = jsonData['daily'] ?? [];
        final forecasts = daily.map((d) => DailyForecast.fromJson(d as Map<String, dynamic>)).toList();
        return forecasts.take(10).toList();
      } else {
        print('Forecast error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }
}
