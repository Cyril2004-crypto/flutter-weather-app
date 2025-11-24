class DailySummary {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double avgTemp;
  final double avgWind;
  final int avgHumidity;
  final String description;
  final String icon;

  DailySummary({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
    required this.avgWind,
    required this.avgHumidity,
    required this.description,
    required this.icon,
  });
}