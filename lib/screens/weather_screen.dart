import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/temperature_utils.dart';
import 'login_screen.dart';

// Main Weather Screen with Event-Driven Programming
class WeatherScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const WeatherScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  
  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String _errorMessage = '';
  String _username = '';
  String _savedCity = '';
  bool _isCelsius = true; // Temperature unit preference

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user preferences (Virtual Identity)
  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _savedCity = prefs.getString('preferredCity') ?? 'London';
      _isCelsius = prefs.getBool('isCelsius') ?? true;
    });
    
    // Load weather for saved city
    if (_savedCity.isNotEmpty) {
      _cityController.text = _savedCity;
      _searchWeather();
    }
  }

  // Theme 2: Event-Driven Programming - Search button event
  _searchWeather() async {
    if (_cityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Theme 3: Interoperability - API call
      final weather = await _weatherService.getWeatherByCity(_cityController.text);
      
      if (weather != null) {
        setState(() {
          _currentWeather = weather;
          _isLoading = false;
        });

        // Save preferred city (Virtual Identity)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('preferredCity', _cityController.text);
      } else {
        setState(() {
          _errorMessage = 'City not found. Please check the spelling.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching weather data: ';
        _isLoading = false;
      });
    }
  }

  // Toggle temperature unit (°C ↔ °F)
  _toggleTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCelsius = !_isCelsius;
    });
    await prefs.setBool('isCelsius', _isCelsius);
  }

  // Logout function (Virtual Identity)
  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_username'),
        actions: [
          // Temperature unit toggle
          IconButton(
            icon: Icon(_isCelsius ? Icons.device_thermostat : Icons.thermostat_outlined),
            onPressed: _toggleTemperatureUnit,
            tooltip: _isCelsius ? 'Switch to Fahrenheit' : 'Switch to Celsius',
          ),
          // Theme toggle
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Search Section (Event-Driven Programming)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      // Temperature unit indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            avatar: Icon(
                              _isCelsius ? Icons.device_thermostat : Icons.thermostat_outlined,
                              size: 18,
                            ),
                            label: Text(
                              'Temperature in ${TemperatureUtils.getUnitName(_isCelsius)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Enter city name',
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _searchWeather, // Event trigger
                          ),
                        ),
                        onSubmitted: (_) => _searchWeather(), // Event trigger
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _searchWeather,
                          icon: const Icon(Icons.search),
                          label: const Text('Search Weather'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Loading indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Error message
              if (_errorMessage.isNotEmpty)
                Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Weather Display
              if (_currentWeather != null && !_isLoading)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Main weather card
                        Card(
                          elevation: 6,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade400, Colors.blue.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _currentWeather!.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  TemperatureUtils.formatTemperature(_currentWeather!.main.temp, _isCelsius),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _currentWeather!.weather[0].description.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Feels like ${TemperatureUtils.formatTemperature(_currentWeather!.main.feelsLike, _isCelsius)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Weather details
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Weather Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                _buildDetailRow(
                                  Icons.thermostat,
                                  'Min/Max',
                                  '${TemperatureUtils.formatTemperature(_currentWeather!.main.tempMin, _isCelsius)} / ${TemperatureUtils.formatTemperature(_currentWeather!.main.tempMax, _isCelsius)}',
                                ),
                                _buildDetailRow(
                                  Icons.water_drop,
                                  'Humidity',
                                  '${_currentWeather!.main.humidity}%',
                                ),
                                _buildDetailRow(
                                  Icons.speed,
                                  'Pressure',
                                  '${_currentWeather!.main.pressure} hPa',
                                ),
                                _buildDetailRow(
                                  Icons.air,
                                  'Wind Speed',
                                  '${_currentWeather!.wind.speed} m/s',
                                ),
                                _buildDetailRow(
                                  Icons.cloud,
                                  'Cloudiness',
                                  '${_currentWeather!.clouds.all}%',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Instructions if no weather data
              if (_currentWeather == null && !_isLoading && _errorMessage.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 80,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Search for a city to see weather data',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
