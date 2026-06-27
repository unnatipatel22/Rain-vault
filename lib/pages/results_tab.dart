import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic>? results;

  const ResultsPage({super.key, this.results});

  Widget _buildFloatingShapes() {
    return Stack(
      children: [
        Positioned(
          top: 60,
          right: 40,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -60,
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
                  Colors.white.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.3),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      {required String title, required IconData icon, required List<Widget> rows}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(icon, color: Colors.white, size: 20),
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
          Column(children: rows),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraph(Map<String, dynamic> results) {
    final double harvest = (results["Harvest Potential (L)"] ?? 0).toDouble();
    final double saving = (results["Annual Water Saving (L)"] ?? 0).toDouble();
    final double demand = (results["Annual Demand (L)"] ?? 0).toDouble();

    if (harvest == 0 && saving == 0) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: const Center(
          child: Text(
            "No data to display",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    final double maxValue = [harvest, saving, demand].reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              const Text(
                "Water Balance Analysis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Harvest Potential Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Harvest Potential: ${harvest.toStringAsFixed(0)} L",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildBar(harvest / maxValue, const Color(0xFF4FC3F7)),
            ],
          ),

          const SizedBox(height: 16),

          // Annual Water Saving Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Annual Water Saving: ${saving.toStringAsFixed(0)} L",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildBar(saving / maxValue, const Color(0xFF4DB6AC)),
            ],
          ),

          const SizedBox(height: 16),

          // Annual Demand Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Annual Demand: ${demand.toStringAsFixed(0)} L",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildBar(demand / maxValue, const Color(0xFFFF7043)),
            ],
          ),

          const SizedBox(height: 16),

          // Coverage Percentage
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Water Coverage:",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${results["Coverage (%)"] ?? 0}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double factor, Color color) {
    return Stack(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        FractionallySizedBox(
          widthFactor: factor.clamp(0.0, 1.0),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to safely get value
  String _getValue(dynamic value, {String suffix = '', String defaultValue = 'N/A'}) {
    if (value == null) return defaultValue;
    if (value is num) return '${value.toStringAsFixed(0)}$suffix';
    return value.toString() + suffix;
  }

  Future<void> _generatePDF(BuildContext context) async {
    if (results == null) return;

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Center(
                child: pw.Text(
                  'Rooftop Rainwater Harvesting Assessment Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated on: ${results!["date"] ?? DateTime.now().toIso8601String().split('T')[0]}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ),
              pw.SizedBox(height: 30),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EXECUTIVE SUMMARY',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Feasibility: ${results!["Feasibility"] ?? "N/A"}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Coverage: ${results!["Coverage (%)"] ?? "N/A"}%',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Harvest Potential: ${_getValue(results!["Harvest Potential (L)"], suffix: " L")}'),
                        pw.Text('Annual Saving: ${_getValue(results!["Annual Water Saving (L)"], suffix: " L")}'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Detailed Results Table
              pw.Text('DETAILED ASSESSMENT RESULTS',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Parameter', 'Value'],
                data: results!.entries.map((e) => [
                  e.key.toString(),
                  e.value?.toString() ?? 'N/A'
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellStyle: const pw.TextStyle(fontSize: 10),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                },
              ),

              pw.SizedBox(height: 20),

              // Recommendations
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RECOMMENDATIONS',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                    pw.SizedBox(height: 10),
                    pw.Text('• Suggested Structure: ${results!["Suggested Structure"] ?? "N/A"}'),
                    pw.Text('• Recommended Storage: ${_getValue(results!["Recommended Storage (L)"], suffix: " L")}'),
                    pw.Text('• Estimated Cost: ₹${_getValue(results!["Estimated Cost (₹)"])}'),
                    pw.Text('• Payback Period: ${_getValue(results!["Payback (years)"], suffix: " years")}'),
                    pw.Text('• Recommended Dimensions: ${results!["Recommended Dimensions"] ?? "N/A"}'),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingShapes(),
            SafeArea(
              child: results == null
                  ? const Center(
                child: Text(
                  "No Results Yet\nComplete the assessment first!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "RTRWH Results",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Water Balance Graph
                    _buildGraph(results!),

                    // Key Metrics Grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard(
                            "Harvest Potential",
                            _getValue(results!["Harvest Potential (L)"], suffix: " L"),
                            Icons.water_drop,
                            const Color(0xFF4FC3F7)),
                        _buildStatCard(
                            "Total Daily Demand",
                            _getValue(results!["Total Daily Water Demand (L)"], suffix: " L/day"),
                            Icons.calendar_today,
                            const Color(0xFF4DB6AC)),
                        _buildStatCard(
                            "Annual Demand",
                            _getValue(results!["Annual Demand (L)"], suffix: " L"),
                            Icons.bar_chart,
                            const Color(0xFF7986CB)),
                        _buildStatCard(
                            "Coverage",
                            _getValue(results!["Coverage (%)"], suffix: "%"),
                            Icons.percent,
                            const Color(0xFF81C784)),
                        _buildStatCard(
                            "Annual Saving",
                            _getValue(results!["Annual Water Saving (L)"], suffix: " L"),
                            Icons.savings,
                            const Color(0xFFFFB74D)),
                        _buildStatCard(
                            "Feasibility",
                            "${results!["Feasibility"] ?? "N/A"}",
                            Icons.check_circle,
                            const Color(0xFFBA68C8)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // System Details
                    _buildDetailCard(
                      title: "System Sizing & Storage",
                      icon: Icons.settings,
                      rows: [
                        _buildRow("Recommended Storage",
                            _getValue(results!["Recommended Storage (L)"], suffix: " L")),
                        _buildRow("Adoption Rate",
                            _getValue(results!["Adoption Rate (%)"], suffix: "%")),
                        _buildRow("Annual Water Saving",
                            _getValue(results!["Annual Water Saving (L)"], suffix: " L")),
                        _buildRow("Suggested Structure",
                            "${results!["Suggested Structure"] ?? "N/A"}"),
                        _buildRow("Recommended Dimensions",
                            "${results!["Recommended Dimensions"] ?? "N/A"}"),
                      ],
                    ),

                    // Water Demand Analysis
                    _buildDetailCard(
                      title: "Water Demand Analysis",
                      icon: Icons.water_outlined,
                      rows: [
                        _buildRow("No. of Households",
                            _getValue(results!["No. of Households"])),
                        _buildRow("Daily Demand per Household",
                            _getValue(results!["Daily Demand per Household (L)"], suffix: " L")),
                        _buildRow("Total Daily Water Demand",
                            _getValue(results!["Total Daily Water Demand (L)"], suffix: " L")),
                        _buildRow("Annual Water Demand",
                            _getValue(results!["Annual Demand (L)"], suffix: " L")),
                      ],
                    ),

                    // Location & Environmental Data
                    _buildDetailCard(
                      title: "Site Information",
                      icon: Icons.location_on,
                      rows: [
                        _buildRow("Location",
                            "${results!["Location"] ?? "Not specified"}"),
                        _buildRow("Roof Area",
                            _getValue(results!["Roof Area (m²)"], suffix: " m²")),
                        _buildRow("Annual Rainfall",
                            _getValue(results!["Annual Rainfall (mm)"], suffix: " mm")),
                        _buildRow("Runoff Coefficient",
                            "${results!["Runoff Coefficient"] ?? "N/A"}"),
                      ],
                    ),

                    // Hydrogeology Info
                    _buildDetailCard(
                      title: "Hydrogeology Info",
                      icon: Icons.water,
                      rows: [
                        _buildRow("Groundwater Depth",
                            _getValue(results!["Groundwater Depth (m)"], suffix: " m")),
                        _buildRow("Aquifer Type",
                            "${results!["Aquifer Type"] ?? "N/A"}"),
                        _buildRow("Historical Rainfall",
                            _getValue(results!["Historical Rainfall (mm)"], suffix: " mm")),
                      ],
                    ),

                    // Cost Analysis
                    _buildDetailCard(
                      title: "Cost Analysis",
                      icon: Icons.currency_rupee,
                      rows: [
                        _buildRow("Estimated Total Cost",
                            "₹${_getValue(results!["Estimated Cost (₹)"])}"),
                        _buildRow("Payback Period",
                            _getValue(results!["Payback (years)"], suffix: " years")),
                      ],
                    ),

                    // Download PDF Button
                    const SizedBox(height: 20),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _generatePDF(context),
                        borderRadius: BorderRadius.circular(15),
                        splashColor: Colors.white24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50),
                                const Color(0xFF45a049),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.download, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'DOWNLOAD DETAILED REPORT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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