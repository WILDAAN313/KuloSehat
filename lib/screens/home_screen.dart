import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'article_detail_screen.dart';
import 'bmi_calculator_screen.dart';
import 'category_screen.dart';
import 'explore_screen.dart';
import 'keluhan_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _articlesFuture;
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _api.getArticles();
    _userFuture = _api.getSavedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildHeroCard(),
              const SizedBox(height: 20),
              _buildQuickAccess(),
              const SizedBox(height: 28),
              _buildLatestArticlesSection(),
              const SizedBox(height: 14),
              _buildArticleList(),
              const SizedBox(height: 28),
              _buildHealthInsightCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Builder(
          builder: (drawerContext) {
            return InkWell(
              onTap: () => Scaffold.of(drawerContext).openDrawer(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu, color: Color(0xFF0D5C9E)),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              final name =
                  snapshot.data?['name'] ??
                  snapshot.data?['fullname'] ??
                  'Alex';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF677C86),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Halo, $name!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2D4A),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Color(0xFF0D5C9E)),
          ),
        ),
      ],
    );
  }

  String _extractString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is Map) {
      return _extractString(
        value['name'] ??
            value['title'] ??
            value['label'] ??
            value['text'] ??
            value['id'],
        fallback,
      );
    }
    return value.toString();
  }

  String _extractCategory(dynamic value) {
    if (value == null) return 'Umum';
    if (value is String) return _normalizeArticleCategory(value);
    if (value is Map) {
      final category = _extractString(
        value['name'] ?? value['title'] ?? value['slug'] ?? value['type'],
        'Umum',
      );
      return _normalizeArticleCategory(category);
    }
    return _normalizeArticleCategory(_extractString(value, 'Umum'));
  }

  String _normalizeArticleCategory(String value) {
    final raw = value.toLowerCase().trim();
    if (raw.contains('kurus') || raw.contains('underweight')) return 'Kurus';
    if (raw.contains('ideal') ||
        raw.contains('normal') ||
        raw.contains('sehat')) {
      return 'Ideal';
    }
    if (raw.contains('gemuk') || raw.contains('overweight')) return 'Gemuk';
    if (raw.contains('obesitas') || raw.contains('obese')) return 'Obesitas';
    return value.trim().isNotEmpty ? value.trim() : 'Umum';
  }

  String _extractImageUrl(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      return (value.startsWith('http://') || value.startsWith('https://'))
          ? value
          : '';
    }
    if (value is Map) {
      return _extractImageUrl(
        value['url'] ?? value['src'] ?? value['image_url'] ?? value['image'],
      );
    }
    return '';
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C9E), Color(0xFF00A876)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kesehatan Anda, Prioritas Kami',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Akses layanan profesional dan pemantauan kesehatan harian dalam satu aplikasi yang cerdas.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 110,
            height: 170,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.health_and_safety,
                color: Colors.white,
                size: 72,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            color: Color(0xFF0F2D4A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          runSpacing: 12,
          spacing: 12,
          children: [
            _tinyCard(
              icon: Icons.article_outlined,
              label: 'Artikel',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
              ),
            ),
            _tinyCard(
              icon: Icons.calculate,
              label: 'BMI',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BmiCalculatorScreen()),
              ),
            ),
            _tinyCard(
              icon: Icons.chat_bubble_outline,
              label: 'Keluhan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KeluhanScreen()),
              ),
            ),
            _tinyCard(
              icon: Icons.category,
              label: 'Penyakit',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tinyCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF0D5C9E), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F2D4A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestArticlesSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Informasi Artikel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F2D4A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Cara sehat untuk kita semua',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF677C86),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExploreScreen()),
          ),
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D5C9E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleList() {
    return FutureBuilder<List<dynamic>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0D5C9E)),
            ),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'Gagal memuat artikel. Periksa koneksi Anda.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: Text('Belum ada artikel tersedia.')),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length.clamp(0, 4),
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final article = Map<String, dynamic>.from(articles[index] ?? {});
              return _buildArticleCarouselCard(article);
            },
          ),
        );
      },
    );
  }

  Widget _buildArticleCarouselCard(Map<String, dynamic> article) {
    final title = _extractString(
      article['title'] ?? article['name'] ?? 'Artikel Kesehatan',
    );
    final excerpt = _extractString(
      article['excerpt'] ??
          article['summary'] ??
          'Baca artikel sehat dan terpercaya.',
    );
    final imageUrl = _extractImageUrl(
      article['image_url'] ?? article['image'] ?? '',
    );
    final category = _extractCategory(
      article['category'] ?? article['type'] ?? 'Umum',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(
              title: title,
              imageUrl: imageUrl.isNotEmpty
                  ? imageUrl
                  : 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2',
              category: category,
              readTime: _extractString(article['read_time'] ?? '5 Menit'),
              content: _extractString(article['content'] ?? excerpt),
              author: _extractString(article['author'] ?? 'Tim Kulo Sehat'),
              publishedAt: _extractString(article['published_at'] ?? ''),
            ),
          ),
        );
      },
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 240,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: const Color(0xFFE8F4ED),
                        child: const Icon(
                          Icons.broken_image,
                          color: Color(0xFF8AAA89),
                          size: 42,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: const Color(0xFFE8F4ED),
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Color(0xFF8AAA89),
                        size: 42,
                      ),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4ED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0D5C9E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      title.isNotEmpty ? title : 'Judul Artikel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F2D4A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Expanded(
                      child: Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF677C86),
                        ),
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

  Widget _buildHealthInsightCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C9E), Color(0xFF00A876)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tip Sehat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Jaga tubuh tetap  sehat dengan berolahraga setiap hari dan mengkonsumsi buah-buahan.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
          SizedBox(height: 18),
          Text(
            'Semangat!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KuloSehat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5C9E),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aplikasi kesehatan lengkap untuk Anda.',
                style: TextStyle(color: Color(0xFF677C86)),
              ),
              const SizedBox(height: 28),
              _drawerItem(Icons.home, 'Beranda', () => Navigator.pop(context)),
              _drawerItem(Icons.article, 'Artikel', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExploreScreen()),
                );
              }),
              _drawerItem(Icons.calculate, 'BMI', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BmiCalculatorScreen(),
                  ),
                );
              }),
              _drawerItem(Icons.chat, 'Keluhan', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KeluhanScreen()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF0D5C9E)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
