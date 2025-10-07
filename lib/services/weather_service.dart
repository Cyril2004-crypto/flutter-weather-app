import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

// Theme 3: Interoperability - API integration with OpenWeatherMap
class WeatherService {
  static const String _apiKey = '085e22f212b11b6c58a6fa2043817cc5'; // Your OpenWeatherMap API key
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
}
