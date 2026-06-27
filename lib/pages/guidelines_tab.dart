import 'package:flutter/material.dart';
import 'login_page.dart';

class GuidelinesTab extends StatelessWidget {
  const GuidelinesTab({super.key});

  Widget _buildGuidelineCard(String title, IconData icon, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.tealAccent.withOpacity(0.2),
                child: Icon(icon, color: Colors.tealAccent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map(
                (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Header =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "RTRWH Guidelines",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    _buildGuidelineCard("Site Selection", Icons.location_pin, [
                      "Choose a roof area with maximum rain exposure.",
                      "Avoid shaded or obstructed areas.",
                      "Ensure easy access for maintenance.",
                    ]),
                    _buildGuidelineCard("Roof & Gutter Maintenance", Icons.roofing, [
                      "Clean roof and gutters regularly.",
                      "Use non-toxic paints and materials.",
                      "Check for leaks and cracks periodically.",
                    ]),
                    _buildGuidelineCard("Storage & Tank Guidelines", Icons.water_drop, [
                      "Use recommended storage type (underground/overhead).",
                      "Ensure tank is covered to prevent contamination.",
                      "Install overflow and inlet filters.",
                      "Regularly clean and inspect tanks.",
                    ]),
                    _buildGuidelineCard("Water Quality & Usage", Icons.opacity, [
                      "Use harvested rainwater primarily for non-potable purposes.",
                      "Install filtration if using for drinking.",
                      "Monitor water quality periodically.",
                    ]),
                    _buildGuidelineCard("Cost & Efficiency Tips", Icons.attach_money, [
                      "Plan storage capacity based on roof area and rainfall.",
                      "Consider modular tanks for scalability.",
                      "Regular maintenance reduces long-term costs.",
                    ]),
                    _buildGuidelineCard("Safety Measures", Icons.shield, [
                      "Ensure structural stability of tanks.",
                      "Install ladders/steps safely.",
                      "Keep children away from open tanks.",
                    ]),
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
