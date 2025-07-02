import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/utils/theme_provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'map_screen.dart';

class WeatherScreen extends StatefulWidget{
  const WeatherScreen({super.key});

  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService = WeatherService();
  late Future<List<Weather>> _weatherFuture;
  double _progess =0.0;
  String _loadindMessage = "We are downloading the data...";
  bool _dataloaded = false;
  bool _showRestartButton =false;
  
  void initState(){
    super.initState();
    _startLoading();
  }
  
  void _startLoading() async{
    setState(() {
      _progess = 0.0;
      _dataloaded = false;
      _showRestartButton = false;
    });
    
    for(int i = 1; i <= 10; i++){
      await Future.delayed(const Duration(milliseconds: 500));
      if(!mounted) return;
      setState(() {
        _progess += 10;
        _loadindMessage = _getLoadingMessage(i);
      });
    }
    
    try{
      _weatherFuture = _fecthWeatherForCities();
      setState(() {
        _dataloaded = true;
        _showRestartButton = true;
      });
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error : unable to retrieve weather data."),
            backgroundColor: Colors.red,
        )
      );
    }
  }

  String _getLoadingMessage(int step){
    if(step < 4) return "We are downloding the data...";
    if(step < 7) return "It's almost finished...";
    return "Just a few seconds left before getting the result...";
  }

  Future<List<Weather>> _fecthWeatherForCities() async{
    try{
      return await _weatherService.getWeatherForMultipleCities();
    }catch (e) {
      throw Exception("Error retrieving weather data : $e");
    }
  }

  void _openMap(String city, double lat, double lon){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MapScreen(latitude: lat, longitude: lon, cityName: city)
      ),
    );
  }

  String _getAnimationForCondition(String condition){
    switch(condition.toLowerCase()){
      case "clear":
        return 'assets/sunny.json';
      case "clouds":
        return 'assets/cloudy.json';
      case "rain":
        return 'assets/rainy.json';
      case "thunderstorm":
        return 'assets/thunderstorm.json';
      case "snow":
        return 'assets/snow.json';
      default:
        return 'assets/cloud.json';
    }
  }
  
  Widget _loadingIndicator(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/loading.json',width: 150,height: 150),
        const SizedBox(height: 20),
        Text(
          _loadindMessage,
          style: const TextStyle(fontSize: 18, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FAProgressBar(
          currentValue: _progess,
          displayText: '%',
          size: 20,
          progressColor: Colors.blue,
          backgroundColor: Colors.grey[300]!,
          animatedDuration: const Duration(milliseconds: 500),
        ),
        const SizedBox(height: 20),
        _showRestartButton
            ? ElevatedButton(
              onPressed: _startLoading,
              child: const Text("Restart"),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget build(BuildContext context){
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Météo"),actions: [
        IconButton(
          icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
          tooltip: isDark ? "Mode clair" : "Mode sombre",
          onPressed: () => themeProvider.toggleTheme(),
        ),
      ],),

      body: Center(
        child: _dataloaded
            ? FutureBuilder<List<Weather>>(
                future: _weatherFuture,
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Error : ${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                              onPressed: _startLoading, 
                              child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }else if(snapshot.hasData){
                    List<Weather> weatherList = snapshot.data!;
                    return Column(
                      children: [
                        Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  columns: const [
                                    DataColumn(
                                        label: Text("City",style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Temperature",style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Condition",style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Animation",style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Map",style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                  ], 
                                  rows: weatherList.map((weather){
                                    return DataRow(cells: [
                                      DataCell(Text(weather.cityName)),
                                      DataCell(Text("${weather.temperature}°C")),
                                      DataCell(Text(weather.condition)),
                                      DataCell(
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Lottie.asset(
                                            _getAnimationForCondition(
                                                weather.condition),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.map,
                                              color: Colors.blue),
                                          onPressed: () => _openMap(
                                            weather.cityName,
                                            weather.latitude,
                                            weather.longitude,
                                          ),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                              ),
                            )
                        ),
                        const SizedBox(height: 100),
                        ElevatedButton(

                            onPressed: _startLoading,
                            child: const Text("Restart")
                        ),
                      ],
                    );
                  }else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            :_loadingIndicator(),
      ),
    );
  }
}

