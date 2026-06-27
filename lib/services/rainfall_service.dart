import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RainfallService {
  // Maximum rainfall per day to avoid extreme spikes
  static const double dailyMaxCap = 50.0; // mm
  static const int movingAverageWindow = 7; // days

  /// Get current device location
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        throw Exception("Location permissions are denied.");
    }
    if (permission == LocationPermission.deniedForever)
      throw Exception("Location permissions are permanently denied.");

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Fetch capped & smoothed annual rainfall (sum of daily precipitation)
  static Future<double> getAnnualRainfall(double lat, double lon,
      {int year = 2022}) async {
    try {
      final start = "$year-01-01";
      final end = "$year-12-31";

      final url =
          "https://archive-api.open-meteo.com/v1/archive"
          "?latitude=$lat&longitude=$lon"
          "&start_date=$start&end_date=$end"
          "&daily=precipitation_sum&timezone=auto";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print("Rainfall request failed: ${response.statusCode}");
        return 0.0;
      }

      final data = jsonDecode(response.body);
      if (data != null &&
          data.containsKey('daily') &&
          data['daily'] != null &&
          data['daily'].containsKey('precipitation_sum')) {
        final List<dynamic> rainList =
        List<dynamic>.from(data['daily']['precipitation_sum']);

        // Cap each day's rainfall
        List<double> cappedRain = rainList.map((v) {
          double val = 0;
          if (v != null) {
            if (v is num) val = v.toDouble();
            else val = double.tryParse(v.toString()) ?? 0;
          }
          return val.clamp(0.0, dailyMaxCap);
        }).toList();

        // Apply 7-day moving average
        List<double> smoothed = List<double>.from(cappedRain);
        for (int i = 0; i < cappedRain.length; i++) {
          int start = i - movingAverageWindow ~/ 2;
          int end = i + movingAverageWindow ~/ 2;
          start = start < 0 ? 0 : start;
          end = end >= cappedRain.length ? cappedRain.length - 1 : end;
          double sum = 0;
          int count = 0;
          for (int j = start; j <= end; j++) {
            sum += cappedRain[j];
            count++;
          }
          smoothed[i] = sum / count;
        }

        // Sum up smoothed rainfall
        double total = smoothed.fold(0.0, (prev, e) => prev + e);
        print("Calculated capped & smoothed annual rainfall: $total mm");
        return total;
      } else {
        print("Rainfall data not found in API response.");
        return 0.0;
      }
    } catch (e, st) {
      print("Error fetching rainfall: $e");
      print(st);
      return 0.0;
    }
  }

  /// Get annual rainfall for current location
  static Future<double> getAnnualRainfallForCurrentLocation({int year = 2022}) async {
    final pos = await getCurrentLocation();
    return await getAnnualRainfall(pos.latitude, pos.longitude, year: year);
  }

  /// Reverse geocoding for human-readable location
  static Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.locality ?? p.subAdministrativeArea ?? 'Unknown'}, "
            "${p.administrativeArea ?? ''}, "
            "${p.country ?? ''}";
      }
      return "Unknown location";
    } catch (e) {
      print("Error reverse geocoding: $e");
      return "Unknown location";
    }
  }

  /// Fetch rainfall + location for current coordinates
  static Future<Map<String, dynamic>> getRainfallAndLocation() async {
    final pos = await getCurrentLocation();
    final rainfall = await getAnnualRainfall(pos.latitude, pos.longitude);
    final locationName = await getLocationName(pos.latitude, pos.longitude);
    return {
      "latitude": pos.latitude,
      "longitude": pos.longitude,
      "rainfall": rainfall,
      "locationName": locationName,
    };
  }

  /// Fetch rainfall + location for given coordinates
  static Future<Map<String, dynamic>> getRainfallAndLocationFor(
      double lat, double lon,
      {int year = 2022}) async {
    final rainfall = await getAnnualRainfall(lat, lon, year: year);
    final locationName = await getLocationName(lat, lon);
    return {
      "latitude": lat,
      "longitude": lon,
      "rainfall": rainfall,
      "locationName": locationName,
    };
  }
}
