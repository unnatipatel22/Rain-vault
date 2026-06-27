import 'package:flutter/material.dart';
import 'package:rain_vault/pages/assessment_tab.dart';
import 'package:rain_vault/pages/results_tab.dart';
import 'package:rain_vault/pages/guidelines_tab.dart';

class RTRWHDashboard extends StatefulWidget {
  final int initialIndex;
  const RTRWHDashboard({super.key, this.initialIndex = 0});

  @override
  State<RTRWHDashboard> createState() => _RTRWHDashboardState();
}

class _RTRWHDashboardState extends State<RTRWHDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic>? _results;

  final Map<String, dynamic> defaultResults = {
    "Harvest Potential (L)": 0,
    "Feasibility": "N/A",
    "Suggested Structure": "N/A",
    "Historical Rainfall (mm)": 0,
    "Groundwater Depth (m)": 0,
    "Aquifer Type": "Unknown",
    "Annual Water Saving (L)": 0,
    "Estimated Cost (₹)": 0,
    "Payback (years)": "0.0",
    "Coverage (%)": 0,
    "Daily Demand (L/day)": 0,
    "Annual Demand (L)": 0,
    "Runoff Generation Capacity (L)": 0,
    "Recommended Storage (L)": 0,
    "Adoption Rate (%)": 0,
  };

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      RTRWHAssessmentPage(
        onResultCalculated: (res) {
          setState(() {
            _results = res;
            _currentIndex = 1;
          });
        },
      ),
      ResultsPage(results: _results ?? defaultResults),
      const GuidelinesTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F2A44),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.white70,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined), label: "Assessment"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined), label: "Results"),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: "Guidelines"),
        ],
      ),
    );
  }
}
