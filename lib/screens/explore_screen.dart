import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'article_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  List<dynamic> _articles = [];
  List<dynamic> _filteredArticles = [];
  bool _isLoading = true;
  String _selectedCategory = 'Semua';

  static const List<String> _articleCategoryLabels = [
    'Semua',
    'Kurus',
    'Ideal',
    'Gemuk',
    'Obesitas',
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.trim();
      _filterArticles();
    });
  }

  Future<void> _loadArticles() async {
    final articles = await _api.getArticles();
    setState(() {
      _articles = articles;
      _filteredArticles = List.from(articles);
      _isLoading = false;
    });
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
    if (raw.contains('kurus') || raw.contains('underweight')) {
      return 'Kurus';
    }
    if (raw.contains('ideal') ||
        raw.contains('normal') ||
        raw.contains('sehat')) {
      return 'Ideal';
    }
    if (raw.contains('gemuk') || raw.contains('overweight')) {
      return 'Gemuk';
    }
    if (raw.contains('obesitas') || raw.contains('obese')) {
      return 'Obesitas';
    }
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

  void _filterArticles() {
    final query = _searchQuery.value.toLowerCase();
    final category = _selectedCategory.toLowerCase();
    setState(() {
      _filteredArticles = _articles.where((item) {
        final article = item as Map<String, dynamic>;
        final title = _extractString(
          article['title'] ?? article['name'] ?? '',
        ).toLowerCase();
        final excerpt = _extractString(
          article['excerpt'] ?? article['summary'] ?? '',
        ).toLowerCase();
        final cat = _extractCategory(
          article['category'] ?? article['type'] ?? 'Umum',
        ).toLowerCase();
        final matchesQuery =
            query.isEmpty || title.contains(query) || excerpt.contains(query);
        final matchesCategory = category == 'semua' || cat == category;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  List<String> get _categories {
    return _articleCategoryLabels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6FAF8),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Jelajah Artikel'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderPanel(),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildPopularSection(),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _CategoryTabsHeader(
                        minExtentValue: 96,
                        maxExtentValue: 96,
                        child: Container(
                          color: const Color(0xFFF6FAF8),
                          padding: const EdgeInsets.only(top: 4, bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                title: 'Artikel Terbaru',
                                subtitle: '${_filteredArticles.length} bacaan',
                              ),
                              const SizedBox(height: 10),
                              _buildCategoryTabs(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildArticleSliverList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D5C9E),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artikel Kesehatan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Bacaan sesuai kategori BMI untuk keputusan sehat harian.',
                  style: TextStyle(
                    color: Color(0xFFD8F1EA),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EEE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF0D5C9E)),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari artikel kesehatan...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.value.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchQuery.value = '';
                _filterArticles();
              },
              child: const Icon(Icons.close, color: Color(0xFF0D5C9E)),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _filterArticles();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF0D5C9E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF0D5C9E)
                      : const Color(0xFFDCEBE6),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF0D5C9E),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularSection() {
    if (_filteredArticles.isEmpty) {
      return const Text(
        'Tidak ada artikel untuk kategori ini.',
        style: TextStyle(color: Color(0xFF677C74)),
      );
    }

    final feature = _filteredArticles.first as Map<String, dynamic>;
    final title = _extractString(
      feature['title'] ?? feature['name'] ?? 'Panduan Kesehatan',
    );
    final excerpt = _extractString(
      feature['excerpt'] ??
          feature['summary'] ??
          'Pelajari tips gaya hidup sehat hari ini.',
    );
    final imageUrl = _extractImageUrl(
      feature['image_url'] ?? feature['image'] ?? '',
    );
    final category = _extractCategory(
      feature['category'] ?? feature['type'] ?? 'Umum',
    );

    return GestureDetector(
      onTap: () => _openArticle(feature),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE1EEE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 118,
                      width: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImageFallback(
                        height: 118,
                        width: 112,
                      ),
                    )
                  : _buildImageFallback(height: 118, width: 112),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Pilihan',
                        style: TextStyle(
                          color: Color(0xFF0D5C9E),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Color(0xFF8AA39B),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF14384C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF627B75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF0D5C9E),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14384C),
            ),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF627B75),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildArticleSliverList() {
    if (_filteredArticles.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Tidak ada artikel yang cocok. Coba kata kunci lain.',
            style: TextStyle(color: Color(0xFF677C74)),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: _filteredArticles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final article = _filteredArticles[index] as Map<String, dynamic>;
        final title = _extractString(
          article['title'] ?? article['name'] ?? 'Artikel kesehatan',
        );
        final excerpt = _extractString(
          article['excerpt'] ??
              article['summary'] ??
              'Baca info kesehatan terpercaya.',
        );
        final imageUrl = _extractImageUrl(
          article['image_url'] ?? article['image'] ?? '',
        );
        final category = _extractCategory(
          article['category'] ?? article['type'] ?? 'Umum',
        );
        final readTime = _extractString(article['read_time'] ?? '5 Menit');

        return GestureDetector(
          onTap: () => _openArticle(article),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1EEE8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 96,
                          width: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageFallback(
                            height: 96,
                            width: 96,
                          ),
                        )
                      : _buildImageFallback(height: 96, width: 96),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7F1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Color(0xFF0D5C9E),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              readTime,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF8AA39B),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14384C),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF627B75),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8AA39B),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageFallback({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE8F4ED),
      child: const Icon(
        Icons.article_outlined,
        color: Color(0xFF8AAA89),
        size: 34,
      ),
    );
  }

  void _openArticle(Map<String, dynamic> article) {
    final title = _extractString(
      article['title'] ?? article['name'] ?? 'Artikel kesehatan',
    );
    final excerpt = _extractString(
      article['excerpt'] ??
          article['summary'] ??
          'Baca info kesehatan terpercaya.',
    );
    final imageUrl = _extractImageUrl(
      article['image_url'] ?? article['image'] ?? '',
    );
    final category = _extractCategory(
      article['category'] ?? article['type'] ?? 'Umum',
    );
    final readTime = _extractString(article['read_time'] ?? '5 Menit');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          title: title,
          imageUrl: imageUrl.isNotEmpty
              ? imageUrl
              : 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2',
          category: category,
          readTime: readTime,
          content: _extractString(article['content'] ?? excerpt),
          author: _extractString(article['author'] ?? 'Tim Kulo Sehat'),
          publishedAt: _extractString(article['published_at'] ?? ''),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _CategoryTabsHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minExtentValue;
  final double maxExtentValue;

  const _CategoryTabsHeader({
    required this.child,
    required this.minExtentValue,
    required this.maxExtentValue,
  });

  @override
  double get minExtent => minExtentValue;

  @override
  double get maxExtent => maxExtentValue;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _CategoryTabsHeader oldDelegate) {
    return child != oldDelegate.child ||
        minExtentValue != oldDelegate.minExtentValue ||
        maxExtentValue != oldDelegate.maxExtentValue;
  }
}
