import 'package:flutter/material.dart';
import 'bmi_calculator_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBFF),
        automaticallyImplyLeading: false,
        title: const Text(
          'KuloSehat',
          style: TextStyle(
            color: Color(0xFF0D5C9E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF0D5C9E),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 20),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroSection(),
            const SizedBox(height: 18),
            // Feature cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: _featureCard(
                            icon: Icons.medical_services,
                            title: 'Chat Dokter',
                            label: 'KONSULTASI',
                            color: const Color(0xFF0D5C9E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: _featureCard(
                            icon: Icons.article_outlined,
                            title: 'Tips Sehat',
                            label: 'ARTIKEL',
                            color: const Color(0xFFE3F2FD),
                            textColor: const Color(0xFF0D5C9E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: _featureCard(
                            icon: Icons.menu_book_rounded,
                            title: 'Panduan Penyakit',
                            label: 'PANDUAN',
                            color: const Color(0xFFFFFFFF),
                            textColor: const Color(0xFF0D5C9E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BmiCalculatorScreen(),
                              ),
                            );
                          },
                          child: _featureCard(
                            icon: Icons.calculate_rounded,
                            title: 'Kalkulator BMI',
                            label: 'KALKULATOR',
                            color: const Color(0xFFDCF8EE),
                            textColor: const Color(0xFF0A7C62),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _healthClosingSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _heroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D5C9E), Color(0xFF1278B8), Color(0xFF1AC2B0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Text(
              'Layanan kesehatan digital untuk aktivitas harian',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mulai rawat kesehatan dengan langkah yang lebih simpel.',
            style: TextStyle(
              fontSize: 29,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pantau kebutuhan kesehatan, baca info penting, dan lanjut ke konsultasi dari satu tempat yang rapi.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _heroStat(icon: Icons.favorite_outline, label: 'Lebih cepat'),
              const SizedBox(width: 12),
              _heroStat(icon: Icons.shield_outlined, label: 'Lebih aman'),
            ],
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F6FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_outward_rounded,
                        color: Color(0xFF0D5C9E),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mulai Sekarang',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF12324A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Masuk untuk lanjut ke layanan KuloSehat',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF5D7285),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0D5C9E),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String label,
    required Color color,
    Color? textColor,
  }) {
    final isDark =
        color == const Color(0xFF0D5C9E) || color == const Color(0xFF12324A);
    final resolvedTextColor = textColor ?? const Color(0xFF0D5C9E);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? null
            : Border.all(color: const Color(0xFFE2EEF7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white : resolvedTextColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? Colors.white70
                  : resolvedTextColor.withValues(alpha: 0.9),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : resolvedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthClosingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2EEF7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Mari jaga kesehatan',
              style: TextStyle(
                color: Color(0xFF0D5C9E),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kesehatan yang baik dimulai dari keputusan kecil yang konsisten.',
            style: TextStyle(
              fontSize: 24,
              height: 1.28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10324A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bangun kebiasaan yang lebih terarah, pahami kondisi tubuh lebih cepat, dan siapkan langkah yang tepat melalui layanan kesehatan yang lebih praktis.',
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Color(0xFF5E7384),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF4FAFF), Color(0xFFEAF8F5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Color(0xFF0D5C9E),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mulai lebih sadar dengan kesehatan Anda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF12324A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Akses informasi, konsultasi, dan panduan yang membantu Anda menjaga kualitas hidup setiap hari.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: Color(0xFF66808D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D5C9E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Lanjut ke Layanan Kesehatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
