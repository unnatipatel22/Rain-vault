import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rain_vault/services/rainfall_service.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedLocation;
  String locationName = "";
  double? rainfall;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation ?? LatLng(20.5937, 78.9629); // Default India
  }

  Future<void> _updateLocationData(LatLng pos) async {
    setState(() {
      selectedLocation = pos;
      rainfall = null; // reset while fetching
      locationName = "Fetching...";
    });

    final rain = await RainfallService.getAnnualRainfall(pos.latitude, pos.longitude);
    final name = await RainfallService.getLocationName(pos.latitude, pos.longitude);

    setState(() {
      rainfall = rain;
      locationName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: selectedLocation!,
                zoom: 5,
              ),
              onTap: (latLng) => _updateLocationData(latLng),
              markers: selectedLocation != null
                  ? {
                Marker(markerId: MarkerId("selected"), position: selectedLocation!)
              }
                  : {},
            ),
          ),
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    "📍 $locationName",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rainfall != null
                        ? "🌧 Annual Rainfall: ${rainfall!.toStringAsFixed(2)} mm"
                        : "Fetching rainfall...",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, {
              "latLng": selectedLocation,
              "rainfall": rainfall,
              "locationName": locationName,
            });
          }
        },
      ),
    );
  }
}
