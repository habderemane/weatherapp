import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl = "https://api.openweathermap.org/data/2.5/";
  static const String apiKey = "e2aae24267ec105fe2366c21c73ce6e8";

  // Liste des villes avec leurs coordonnées
  final List<Map<String, dynamic>> cities = [
    {"name": "Paris", "lat": -11.7172, "lon": 43.2473},
    {"name": "Seoul", "lat": 37.7617, "lon": -80.1918},
    {"name": "Thies", "lat": -4.3947, "lon": 19.5582},
    {"name": "kyoto", "lat": -17.6895, "lon": 210.6917},
    {"name": "Dakar", "lat": 14.6928, "lon": -17.4467},
  ];

  // Récupérer la météo pour une ville spécifique
  Future<Weather> getWeather(String city) async {
    final url = Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather(
        cityName: data['name'],
        temperature: data['main']['temp'].toDouble(),
        condition: data['weather'][0]['main'],
        latitude: data['coord']['lat'].toDouble(),
        longitude: data['coord']['lon'].toDouble(),
      );
    } else {
      throw Exception("Failed to retrieve weather data $city.");
    }
  }

  // Récupérer la météo pour plusieurs villes
  Future<List<Weather>> getWeatherForMultipleCities() async {
    List<Weather> weatherData = [];
    for (var city in cities) {
      try {
        final cityName = city["name"];
        Weather weather = await getWeather(cityName);
        weatherData.add(weather);
      } catch (e) {
        print("Error for ${city["name"]}: $e");
      }
    }
    return weatherData;
  }

  // Vérifier et demander la permission de localisation
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return false; // Permission refusée définitivement
      }
    }
    return permission != LocationPermission.denied;
  }

  // Obtenir la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    final hasPermission = await checkLocationPermission();
    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      throw Exception("Location permission required.");
    }
  }

  // Récupérer la météo pour la position actuelle
  Future<Weather> getWeatherForCurrentLocation() async {
    final position = await getCurrentPosition();
    final url = Uri.parse(
        '$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather(
        cityName: data['name'],
        temperature: data['main']['temp'].toDouble(),
        condition: data['weather'][0]['main'],
        latitude: data['coord']['lat'].toDouble(),
        longitude: data['coord']['lon'].toDouble(),
      );
    } else {
      throw Exception("Failed to retrieve weather data for your current location.");
    }
  }
}