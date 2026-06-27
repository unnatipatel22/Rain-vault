import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/rainfall_service.dart';

class MapPickerPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapPickerPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location"),),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 12,
        ),
        onMapCreated: (controller) => _mapController = controller,
        onTap: (LatLng position) {
          setState(() {
            _selectedLocation = position;
          });
        },
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: const MarkerId("selected"),
            position: _selectedLocation!,
          )
        }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          if (_selectedLocation != null) {
            final lat = _selectedLocation!.latitude;
            final lon = _selectedLocation!.longitude;

            // ✅ Fetch rainfall
            final rainfall =
            await RainfallService.getAnnualRainfall(lat, lon);

            // ✅ Fetch human-readable name
            final locationName =
            await RainfallService.getLocationName(lat, lon);

            // ✅ Send back to previous screen
            Navigator.pop(context, {
              "latitude": lat,
              "longitude": lon,
              "rainfall": rainfall,
              "locationName": locationName,
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select a location on the map")),
            );
          }
        },
      ),
    );
  }
}
