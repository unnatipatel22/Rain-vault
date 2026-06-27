import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/rainfall_service.dart';
import 'map_picker_page.dart';
import 'package:rain_vault/pages/history.dart';

class RTRWHAssessmentPage extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onResultCalculated;
  const RTRWHAssessmentPage({super.key, this.onResultCalculated});

  @override
  State<RTRWHAssessmentPage> createState() => _RTRWHAssessmentPageState();
}

class _RTRWHAssessmentPageState extends State<RTRWHAssessmentPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _roofAreaController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _householdsController = TextEditingController();
  final TextEditingController _waterDemandController = TextEditingController(text: '150');
  final TextEditingController _openSpaceController = TextEditingController();

  String _selectedRunoffCoeff = '0.8';

  double _runoffVolume = 0;
  String _feasibility = '';
  String _suggestedStructure = '';
  double _annualSaving = 0;
  double _estimatedCost = 0;
  double _payback = 0;
  double _groundwaterDepth = 5;
  String _aquiferType = 'Alluvial';
  double _historicalRainfall = 800;

  // Total daily water demand calculation
  double _totalDailyWaterDemand = 0;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  List<Map<String, dynamic>> history = [];

  // Show results flag
  bool _showResults = false;
  Map<String, dynamic> _currentResults = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadHistory();
    _calculateTotalDailyDemand();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedHistory = prefs.getStringList('rtrwh_history') ?? [];
    setState(() {
      history = storedHistory.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  void _calculateTotalDailyDemand() {
    double dailyDemandPerUnit = double.tryParse(_waterDemandController.text) ?? 150;
    double noOfHouseholds = double.tryParse(_householdsController.text) ?? 0;

    setState(() {
      _totalDailyWaterDemand = dailyDemandPerUnit * noOfHouseholds;
    });

    _updateSummary();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _roofAreaController.dispose();
    _rainfallController.dispose();
    _locationController.dispose();
    _householdsController.dispose();
    _waterDemandController.dispose();
    _openSpaceController.dispose();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enable location services")));
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Location permission denied")));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission permanently denied")));
      return false;
    }
    return true;
  }

  Future<void> _autoFillRainfallAndLocation() async {
    try {
      bool hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;

      final result = await RainfallService.getRainfallAndLocation();
      setState(() {
        _rainfallController.text = result['rainfall'].toStringAsFixed(1);
        _locationController.text = result['locationName'];
        _historicalRainfall = result['rainfall'];
        _aquiferType = result['aquifer'] ?? 'Alluvial';
        _groundwaterDepth = result['groundwaterDepth'] ?? 5;
      });

      _updateSummary();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching rainfall/location: $e")));
    }
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPickerPage(latitude: 20.5937, longitude: 78.9629),
      ),
    );

    if (result != null) {
      setState(() {
        _rainfallController.text = (result['rainfall'] as double).toStringAsFixed(1);
        _locationController.text = result['locationName'];
        _historicalRainfall = result['rainfall'];
        _aquiferType = result['aquifer'] ?? 'Alluvial';
        _groundwaterDepth = result['groundwaterDepth'] ?? 5;
      });
      _updateSummary();
    }
  }

  void _updateSummary() {
    double roofArea = double.tryParse(_roofAreaController.text) ?? 0;
    double rainfall = double.tryParse(_rainfallController.text) ?? _historicalRainfall;
    double runoffCoeff = double.tryParse(_selectedRunoffCoeff) ?? 0.8;
    double openSpace = double.tryParse(_openSpaceController.text) ?? 0;

    _runoffVolume = roofArea * rainfall * runoffCoeff;

    if (_runoffVolume < 5000) {
      _feasibility = 'Low';
    } else if (_runoffVolume < 20000) {
      _feasibility = 'Medium';
    } else {
      _feasibility = 'High';
    }

    if (roofArea < 100 && openSpace >= 10) {
      _suggestedStructure = 'Small Pit';
    } else if (roofArea <= 500) {
      _suggestedStructure = 'Trench';
    } else {
      _suggestedStructure = 'Shaft';
    }

    _annualSaving = _runoffVolume * 0.7;
    _estimatedCost = roofArea * 50 + 50000;
    _payback = _annualSaving > 0 ? _estimatedCost / _annualSaving : 0;

    setState(() {});
  }

  void _calculateRTRWH() async {
    // Validation - Check if required fields are filled
    if (_roofAreaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter roof area')),
      );
      return;
    }

    if (_householdsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter number of households')),
      );
      return;
    }

    // Auto-fill location if empty
    if (_locationController.text.isEmpty || _rainfallController.text.isEmpty) {
      await _autoFillRainfallAndLocation();
    }

    // Recalculate everything
    _updateSummary();
    _calculateTotalDailyDemand();

    double dailyDemandPerUnit = double.tryParse(_waterDemandController.text) ?? 150;
    double noOfHouseholds = double.tryParse(_householdsController.text) ?? 1;
    double annualDemand = _totalDailyWaterDemand * 365;
    double coveragePercent = annualDemand > 0 ? (_annualSaving / annualDemand) * 100 : 0;
    coveragePercent = coveragePercent > 100 ? 100 : coveragePercent;
    double recommendedStorage = _annualSaving * 0.5;
    double adoptionRate = 80;
    String recommendedDimensions = "${(recommendedStorage / 1000).toStringAsFixed(1)} m³";

    _currentResults = {
      "date": DateTime.now().toIso8601String().split('T')[0],
      "Location": _locationController.text.isEmpty ? "Not specified" : _locationController.text,
      "Roof Area (m²)": double.tryParse(_roofAreaController.text) ?? 0,
      "Annual Rainfall (mm)": double.tryParse(_rainfallController.text) ?? _historicalRainfall,
      "Runoff Coefficient": double.tryParse(_selectedRunoffCoeff) ?? 0.8,
      "Harvest Potential (L)": _runoffVolume.round(),
      "Feasibility": _feasibility,
      "Suggested Structure": _suggestedStructure,
      "Historical Rainfall (mm)": _historicalRainfall,
      "Groundwater Depth (m)": _groundwaterDepth,
      "Aquifer Type": _aquiferType,
      "Annual Water Saving (L)": _annualSaving.round(),
      "Estimated Cost (₹)": _estimatedCost.round(),
      "Payback (years)": _payback.toStringAsFixed(1),
      "No. of Households": noOfHouseholds.round(),
      "Daily Demand per Household (L)": dailyDemandPerUnit.round(),
      "Total Daily Water Demand (L)": _totalDailyWaterDemand.round(),
      "Annual Demand (L)": annualDemand.round(),
      "Coverage (%)": coveragePercent.round(),
      "Recommended Storage (L)": recommendedStorage.round(),
      "Adoption Rate (%)": adoptionRate,
      "Recommended Dimensions": recommendedDimensions,
    };

    // Save to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedHistory = prefs.getStringList('rtrwh_history') ?? [];
    storedHistory.add(jsonEncode(_currentResults));
    await prefs.setStringList('rtrwh_history', storedHistory);

    // Update local history list
    setState(() {
      history.add(_currentResults);
      _showResults = true; // Show results section
    });

    if (widget.onResultCalculated != null) {
      widget.onResultCalculated!(_currentResults);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculation completed! Results shown below.')),
    );
  }

  Widget _buildModernTextField(TextEditingController controller, String label, String? suffix, {bool isWaterDemandField = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: suffix == 'm²' ? 'e.g. 100' : suffix == 'mm' ? 'e.g. 800' : suffix == 'L/day' ? 'e.g. 150' : 'Enter value',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
                suffixText: suffix,
                suffixStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
              onChanged: (value) {
                if (isWaterDemandField) {
                  _calculateTotalDailyDemand();
                } else {
                  _updateSummary();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDemandDisplay() {
    if (_totalDailyWaterDemand <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.2),
            const Color(0xFF059669).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL DAILY WATER DEMAND',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_totalDailyWaterDemand.toStringAsFixed(0)} L/day',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.water_drop,
                color: const Color(0xFF10B981),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Annual: ${(_totalDailyWaterDemand * 365).toStringAsFixed(0)} L/year',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Results display widget
  Widget _buildResultsSection() {
    if (!_showResults || _currentResults.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF059669).withOpacity(0.2),
            const Color(0xFF047857).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                'ASSESSMENT RESULTS',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Key Results Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildResultCard('Harvest Potential', '${_currentResults["Harvest Potential (L)"]} L', Icons.water_drop),
              _buildResultCard('Feasibility', '${_currentResults["Feasibility"]}', Icons.thumbs_up_down),
              _buildResultCard('Annual Saving', '${_currentResults["Annual Water Saving (L)"]} L', Icons.savings),
              _buildResultCard('Coverage', '${_currentResults["Coverage (%)"]}%', Icons.pie_chart),
            ],
          ),

          const SizedBox(height: 20),

          // Detailed Results
          _buildDetailedResults(),
        ],
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResults() {
    List<MapEntry<String, dynamic>> details = _currentResults.entries
        .where((entry) => ![
      'date',
      'Harvest Potential (L)',
      'Feasibility',
      'Annual Water Saving (L)',
      'Coverage (%)'
    ].contains(entry.key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETAILED BREAKDOWN',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        ...details.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'LOCATION',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter location or use GPS',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white70),
                  onPressed: _autoFillRainfallAndLocation,
                ),
                IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.white70),
                  onPressed: _pickLocationFromMap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'RUNOFF COEFFICIENT',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRunoffCoeff,
                isExpanded: true,
                dropdownColor: const Color(0xFF6B46C1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                items: const [
                  DropdownMenuItem(value: '0.8', child: Text('0.8 - Concrete/Tile roof')),
                  DropdownMenuItem(value: '0.7', child: Text('0.7 - Asbestos sheets')),
                  DropdownMenuItem(value: '0.9', child: Text('0.9 - Metal sheets')),
                  DropdownMenuItem(value: '0.6', child: Text('0.6 - Thatched roof')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRunoffCoeff = value!;
                    _updateSummary();
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: _calculateRTRWH,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF7C3AED),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calculate, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'CALCULATE RTRWH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: 30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.3),
                  const Color(0xFF0EA5E9).withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(80),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: 50,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupContainer(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryPage()),
          );
        },
        child: const Icon(Icons.history),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF06B6D4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingShapes(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Back button and heading row
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'RTRWH ASSESSMENT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Property Information Group
                    _buildGroupContainer(
                      'Property Information',
                      [
                        _buildModernTextField(_roofAreaController, 'Roof Area', 'm²'),
                        _buildModernTextField(_openSpaceController, 'Open Space Available', 'm²'),
                        _buildDropdownField(),
                      ],
                    ),

                    // Location & Climate Group
                    _buildGroupContainer(
                      'Location & Climate',
                      [
                        _buildLocationRow(),
                        _buildModernTextField(_rainfallController, 'Annual Rainfall', 'mm'),
                      ],
                    ),

                    // Water Demand Group
                    _buildGroupContainer(
                      'Water Demand Analysis',
                      [
                        _buildModernTextField(_householdsController, 'Number of Dwellers', null, isWaterDemandField: true),
                        _buildModernTextField(_waterDemandController, 'Daily Water Demand per Household', 'L/day', isWaterDemandField: true),
                        _buildTotalDemandDisplay(),
                      ],
                    ),

                    _buildCalculateButton(),

                    // Results Section
                    _buildResultsSection(),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}