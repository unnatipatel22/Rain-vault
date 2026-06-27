import 'package:flutter/material.dart';
import 'package:rain_vault/services/rainfall_service.dart';

class AnnualRainfallScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const AnnualRainfallScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<AnnualRainfallScreen> createState() => _AnnualRainfallScreenState();
}

class _AnnualRainfallScreenState extends State<AnnualRainfallScreen> {
  double? _annualRainfall;
  bool _loading = false;
  String? _error;
  String _locationName = '';

  @override
  void initState() {
    super.initState();
    _fetchRainfall();
  }

  Future<void> _fetchRainfall() async {
    setState(() {
      _loading = true;
      _error = null;
      _annualRainfall = null;
    });

    try {
      // Fetch rainfall and location
      double rain = await RainfallService.getAnnualRainfall(widget.latitude, widget.longitude);
      String locationName = await RainfallService.getLocationName(widget.latitude, widget.longitude);

      setState(() {
        _annualRainfall = rain;
        _locationName = locationName;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _submitRainfall() {
    if (_annualRainfall != null) {
      Navigator.pop(context, {
        'rainfall': _annualRainfall,
        'locationName': _locationName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Annual Rainfall")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
            ? Text("Error: $_error")
            : _annualRainfall != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Location: $_locationName",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Annual Rainfall: ${_annualRainfall!.toStringAsFixed(1)} mm",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitRainfall,
              icon: const Icon(Icons.check),
              label: const Text("Use this value"),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: _fetchRainfall,
          child: const Text("Fetch Annual Rainfall"),
        ),
      ),
    );
  }
}
