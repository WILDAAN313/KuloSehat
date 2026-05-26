import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.readTime,
    this.content = '',
    this.author = 'Tim Kulo Sehat',
    this.publishedAt = '',
  });

  final String title;
  final String imageUrl;
  final String category;
  final String readTime;
  final String content;
  final String author;
  final String publishedAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBFF),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Detail Artikel'),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_headerImage(), _contentCard()],
        ),
      ),
    );
  }

  Widget _headerImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Image.network(
        imageUrl,
        height: 260,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 260,
          color: const Color(0xFFE8F4ED),
          child: const Icon(
            Icons.broken_image,
            size: 56,
            color: Color(0xFF8AAA89),
          ),
        ),
      ),
    );
  }

  Widget _contentCard() {
    return Container(
      transform: Matrix4.translationValues(0, -24, 0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C9E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF0D5C9E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                readTime,
                style: const TextStyle(color: Color(0xFF677C86), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F2D4A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author,
                    style: const TextStyle(
                      color: Color(0xFF0F2D4A),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    publishedAt.isNotEmpty ? publishedAt : '01 januari 2026',
                    style: const TextStyle(
                      color: Color(0xFF9DB7AF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF4F636F),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Langkah Praktis Pencegahan',
            style: TextStyle(
              color: Color(0xFF0D5C9E),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),
          _bullet(
            'Cuci tangan rutin dengan sabun selama minimal 20 detik setiap hari.',
          ),
          _bullet(
            'Konsumsi buah dan sayur segar setiap hari untuk menjaga imunitas.',
          ),
          _bullet('Tidur nyenyak 7-8 jam untuk membantu pemulihan tubuh.'),
          _bullet(
            'Hindari stres berlebihan dengan olahraga ringan secara konsisten.',
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle, color: Color(0xFF0D5C9E), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4F636F),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
