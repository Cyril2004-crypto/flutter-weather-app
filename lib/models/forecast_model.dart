// ...new file...
class DailyForecast {
  final int dt;
  final double tempDay;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int clouds;
  final String description;
  final String icon;

  DailyForecast({
    required this.dt,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.clouds,
    required this.description,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['temp'] ?? {};
    final weather = (json['weather'] as List<dynamic>?)?.first ?? {};
    return DailyForecast(
      dt: json['dt'] ?? 0,
      tempDay: (temp['day'] ?? 0).toDouble(),
      tempMin: (temp['min'] ?? 0).toDouble(),
      tempMax: (temp['max'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toInt(),
      pressure: (json['pressure'] ?? 0).toInt(),
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      clouds: (json['clouds'] ?? 0).toInt(),
      description: (weather['description'] ?? '').toString(),
      icon: (weather['icon'] ?? '').toString(),
    );
  }
}
// ...end file...