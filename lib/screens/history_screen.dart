import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<dynamic> _history = [];
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  Future<void> _loadHistory() async {
    List<dynamic> history = await _api.getHistory();
    if (history.isEmpty) {
      history = await _api.getKeluhan();
    }
    setState(() {
      _history = history;
      _filtered = List.from(history);
      _isLoading = false;
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = _history.where((item) {
        final data = item as Map<String, dynamic>;
        final title = (data['title'] ?? data['subject'] ?? '')
            .toString()
            .toLowerCase();
        final status = (data['status'] ?? '').toString().toLowerCase();
        return title.contains(query) || status.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBF7),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Riwayat Konsultasi'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              Expanded(child: _buildHistoryList()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF0D5C9E)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari riwayat keluhan atau status...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _filterHistory();
              },
              child: const Icon(Icons.close, color: Color(0xFF0D5C9E)),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada riwayat konsultasi. Kirim keluhan untuk mulai.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF677C74)),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _filtered[index] as Map<String, dynamic>;
        final title = item['title'] ?? item['subject'] ?? 'Keluhan kesehatan';
        final description = item['description'] ?? item['note'] ?? '-';
        final response =
            item['response'] ?? item['answer'] ?? 'Belum ada respon.';
        final status = item['status'] ?? 'menunggu';
        final createdAt = item['created_at'] ?? item['date'] ?? '';

        final isAnswered = status.toString().toLowerCase() == 'dijawab';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D5C9E),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAnswered
                          ? const Color(0xFFE7F8ED)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        color: isAnswered
                            ? const Color(0xFF1F6E47)
                            : const Color(0xFFB16000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF677C74)),
              ),
              const SizedBox(height: 14),
              Text(
                'Jawaban dokter: $response',
                style: const TextStyle(
                  color: Color(0xFF1F6E47),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (createdAt.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  createdAt,
                  style: const TextStyle(
                    color: Color(0xFF9DB7AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
