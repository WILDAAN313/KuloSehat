import 'package:flutter/material.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  double height = 175;
  double weight = 70;
  late final TextEditingController heightController;
  late final TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    heightController = TextEditingController(text: height.toStringAsFixed(0));
    weightController = TextEditingController(text: weight.toStringAsFixed(0));
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  double get bmiValue {
    final meter = height / 100;
    return weight / (meter * meter);
  }

  String get bmiStatus {
    final bmi = bmiValue;
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Gemuk';
    return 'Obesitas';
  }

  Color get bmiColor {
    final bmi = bmiValue;
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _updateHeight(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 100 && parsed <= 250) {
      setState(() => height = parsed);
    }
  }

  void _updateWeight(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 30 && parsed <= 200) {
      setState(() => weight = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF0FFFE),
        foregroundColor: const Color(0xFF1D4B8F),
        title: const Text('Kalkulator BMI'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalkulator BMI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4B8F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hitung Indeks Massa Tubuh Anda secara akurat untuk memantau status kesehatan harian.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF677C74),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _inputCard(
                      label: 'TINGGI BADAN',
                      controller: heightController,
                      unit: 'cm',
                      helperText: 'Rentang: 100 - 250 cm',
                      onChanged: _updateHeight,
                    ),
                    const SizedBox(height: 14),
                    _inputCard(
                      label: 'BERAT BADAN',
                      controller: weightController,
                      unit: 'kg',
                      helperText: 'Rentang: 30 - 200 kg',
                      onChanged: _updateWeight,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4B8F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.calculate),
                        label: const Text(
                          'Hitung Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDAF9E6),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HASIL ANALISIS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4B8F),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              bmiValue.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: bmiColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: bmiColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    bmiStatus,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D4B8F),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Berat badan Anda ideal untuk tinggi badan tersebut.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF38534B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D4B8F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Saran Kesehatan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4B8F),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pertahankan pola makan seimbang dan olahraga teratur minimal 30 menit setiap hari untuk menjaga kebugaran.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF677C74),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required String helperText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 18),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF425255),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: onChanged,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF425255),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            helperText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A9A97)),
          ),
        ],
      ),
    );
  }
}
