import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/rainfall_service.dart';

class RainfallPage extends StatefulWidget {
  const RainfallPage({super.key});

  @override
  State<RainfallPage> createState() => _RainfallPageState();
}

class _RainfallPageState extends State<RainfallPage> {
  String _result = "Press the button to fetch rainfall";

  /// ✅ Step 1: Handle location permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied")),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions are permanently denied.")),
      );
      return false;
    }

    return true;
  }

  /// ✅ Step 2: Reverse geocode to get location name
  Future<String> _getLocationName(Position pos) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['county'] ??
            "Unknown Location";
      }
    } catch (_) {}
    return "Unknown Location";
  }

  /// ✅ Step 3: Fetch rainfall + location
  Future<void> _fetchRainfallAndLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position pos = await RainfallService.getCurrentLocation();
      double rainfall =
      await RainfallService.getAnnualRainfall(pos.latitude, pos.longitude);
      String locationName = await _getLocationName(pos);

      setState(() {
        _result =
        "📍 Location: $locationName\n🌧️ Annual Rainfall: ${rainfall.toStringAsFixed(1)} mm";
      });
    } catch (e) {
      setState(() {
        _result = "❌ Error fetching rainfall/location: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rainfall Checker")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchRainfallAndLocation,
                child: const Text("Get Rainfall & Location"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
