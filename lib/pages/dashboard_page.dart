import 'package:flutter/material.dart';
import 'package:rain_vault/pages/assessment_tab.dart';
import 'package:rain_vault/pages/results_tab.dart';
import 'package:rain_vault/pages/guidelines_tab.dart';
import 'package:rain_vault/pages/login_page.dart';
import 'package:rain_vault/pages/setting_page.dart';
import 'package:rain_vault/navigation.dart';
import 'package:rain_vault/pages/history.dart';

class DashboardPage extends StatelessWidget {
  final String username;
  final VoidCallback onThemeToggle;
  final bool isDarkTheme;

  // Sample history list (you can replace it with real data from storage)
  final List<Map<String, dynamic>> history = [
    {
      "date": "2025-09-22",
      "Harvest Potential (L)": 1200,
      "Annual Water Saving (L)": 900,
      "Coverage (%)": 75,
    },
    {
      "date": "2025-09-21",
      "Harvest Potential (L)": 1000,
      "Annual Water Saving (L)": 800,
      "Coverage (%)": 70,
    },
  ];

  DashboardPage({
    super.key,
    required this.username,
    required this.onThemeToggle,
    required this.isDarkTheme,
  });

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: 40,
          child: Container(
            width: 90,
            height: 90,
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
          bottom: 120,
          left: -40,
          child: Container(
            width: 220,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(80),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.04),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: 60,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "RTRWH",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                                  (route) => false,
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Dashboard Title
                    const Center(
                      child: Text(
                        "DASHBOARD",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Cards
                    Expanded(
                      child: ListView(
                        children: [
                          _buildGlassCard(
                            context,
                            icon: Icons.calculate,
                            title: "Start New Assessment",
                            desc: "Assess rooftop rainwater harvesting potential.",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RTRWHDashboard(initialIndex: 0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGlassCard(
                            context,
                            icon: Icons.analytics_outlined,
                            title: "View Results",
                            desc: "Check your assessment results.",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RTRWHDashboard(initialIndex: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGlassCard(
                            context,
                            icon: Icons.history,
                            title: "History",
                            desc: "View past assessments and results.",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryPage(),
                              ),
                            ),

                          ),
                          const SizedBox(height: 20),
                          _buildGlassCard(
                            context,
                            icon: Icons.info_outline,
                            title: "Guidelines",
                            desc: "Read complete harvesting guidelines.",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RTRWHDashboard(initialIndex: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildGlassCard(
                            context,
                            icon: Icons.settings,
                            title: "Settings",
                            desc: "App preferences, theme & notifications.",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SettingsPage(
                                    onThemeToggle: onThemeToggle,
                                    isDarkTheme: isDarkTheme,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context,
      {required IconData icon,
        required String title,
        required String desc,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
