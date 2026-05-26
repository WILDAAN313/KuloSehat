import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedAge = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061E1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0C3D2E), Color(0xFF061E1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "KuloSehat",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "KATEGORI USIA",
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ageItem(Icons.child_care, "Bayi", 0),
                  ageItem(Icons.directions_run, "Remaja", 1),
                  ageItem(Icons.person, "Dewasa", 2),
                  ageItem(Icons.elderly, "Lansia", 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ageItem(IconData icon, String label, int index) {
    final bool isSelected = selectedAge == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAge = index;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : const Color(0xFF0E2B27),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.greenAccent : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
