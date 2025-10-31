// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
      name: json['name'] as String,
      coord: Coord.fromJson(json['coord'] as Map<String, dynamic>),
      main: Main.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>)
          .map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList(),
      wind: Wind.fromJson(json['wind'] as Map<String, dynamic>),
      clouds: Clouds.fromJson(json['clouds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'coord': instance.coord,
      'main': instance.main,
      'weather': instance.weather,
      'wind': instance.wind,
      'clouds': instance.clouds,
    };

Coord _$CoordFromJson(Map<String, dynamic> json) => Coord(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordToJson(Coord instance) => <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
    };

Main _$MainFromJson(Map<String, dynamic> json) => Main(
      temp: (json['temp'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      pressure: (json['pressure'] as num).toInt(),
      humidity: (json['humidity'] as num).toInt(),
    );

Map<String, dynamic> _$MainToJson(Main instance) => <String, dynamic>{
      'temp': instance.temp,
      'feels_like': instance.feelsLike,
      'temp_min': instance.tempMin,
      'temp_max': instance.tempMax,
      'pressure': instance.pressure,
      'humidity': instance.humidity,
    };

Weather _$WeatherFromJson(Map<String, dynamic> json) => Weather(
      id: (json['id'] as num).toInt(),
      main: json['main'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'id': instance.id,
      'main': instance.main,
      'description': instance.description,
      'icon': instance.icon,
    };

Wind _$WindFromJson(Map<String, dynamic> json) => Wind(
      speed: (json['speed'] as num).toDouble(),
      deg: (json['deg'] as num).toInt(),
    );

Map<String, dynamic> _$WindToJson(Wind instance) => <String, dynamic>{
      'speed': instance.speed,
      'deg': instance.deg,
    };

Clouds _$CloudsFromJson(Map<String, dynamic> json) => Clouds(
      all: (json['all'] as num).toInt(),
    );

Map<String, dynamic> _$CloudsToJson(Clouds instance) => <String, dynamic>{
      'all': instance.all,
    };
