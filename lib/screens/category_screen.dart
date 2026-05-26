import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  String _selectedGroup = 'Bayi';

  static const List<String> _groupLabels = [
    'Bayi',
    'Remaja',
    'Dewasa',
    'Lansia',
  ];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });

    final rawTopics = await _api.getDiseaseTopics(
      categorySlug: _groupSlug(_selectedGroup),
    );
    final topics = _normalizeTopics(rawTopics, _selectedGroup);

    setState(() {
      _categories = topics;
      _isLoading = false;
    });
  }

  String _groupSlug(String label) {
    return label.toLowerCase();
  }

  List<Map<String, dynamic>> _normalizeTopics(
    List<dynamic> raw,
    String selectedGroup,
  ) {
    if (raw.isEmpty) {
      return [];
    }

    final topics = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final name = _readFirstText(item, const [
          'name',
          'nama',
          'title',
          'judul',
          'label',
          'penyakit',
          'nama_penyakit',
          'disease',
          'disease_name',
          'nama_disease',
          'topic',
          'nama_topik',
        ], fallback: 'Topik Penyakit');
        final description = _readTopicContent(item);
        final group = _extractGroup(item, fallback: selectedGroup);
        topics.add({
          'id': item['id'],
          'slug': _readFirstText(item, const [
            'slug',
            'topic_slug',
            'slug_topik',
            'kode',
          ], fallback: ''),
          'name': name,
          'description': description,
          'group': group,
          'raw': item,
        });
        continue;
      }

      final name = item.toString();
      topics.add({
        'name': name,
        'description': 'Informasi penyakit tersedia di sini.',
        'group': selectedGroup,
        'raw': {'name': name},
      });
    }
    return topics;
  }

  String _readTopicContent(Map<String, dynamic> item) {
    final mainText = _readFirstText(item, const [
      'guide',
      'guides',
      'guideline',
      'guidelines',
      'panduan',
      'panduan_penyakit',
      'article',
      'artikel',
      'description',
      'deskripsi',
      'summary',
      'ringkasan',
      'excerpt',
      'intro',
      'introduction',
      'subtitle',
      'materi',
      'isi_singkat',
      'isi_lengkap',
      'full_content',
      'fullContent',
      'content_html',
      'isi_html',
      'html',
      'description_html',
      'text',
      'teks',
      'isi',
      'content',
      'konten',
      'body',
      'detail',
      'details',
      'keterangan',
      'penjelasan',
      'explanation',
      'pengertian',
      'overview',
      'definition',
      'what_is',
      'whatIs',
    ], fallback: '');

    if (mainText.isNotEmpty) return _cleanDisplayText(mainText);

    final sections = <String>[
      _labelContent('Pengertian', item['pengertian'] ?? item['definition']),
      _labelContent('Gejala', item['gejala'] ?? item['symptoms']),
      _labelContent('Penyebab', item['penyebab'] ?? item['causes']),
      _labelContent(
        'Pencegahan',
        item['pencegahan'] ??
            item['prevention'] ??
            item['cara_pencegahan'] ??
            item['preventive_measures'] ??
            item['how_to_prevent'],
      ),
      _labelContent(
        'Rekomendasi',
        item['rekomendasi'] ??
            item['recommendation'] ??
            item['anjuran'] ??
            item['advice'],
      ),
      _labelContent(
        'Solusi',
        item['solusi'] ?? item['treatment'] ?? item['penanganan'],
      ),
      _labelContent(
        'Perawatan',
        item['perawatan'] ?? item['care'] ?? item['tata_laksana'],
      ),
      _labelContent('Risiko', item['risiko'] ?? item['risk'] ?? item['risks']),
      _labelContent('Diagnosis', item['diagnosis']),
      _labelContent('Komplikasi', item['komplikasi'] ?? item['complications']),
      _readContentText(item['sections'] ?? item['section']),
      _readContentText(item['guides'] ?? item['guide']),
      _readContentText(item['guidelines'] ?? item['guideline']),
      _readContentText(item['steps'] ?? item['step']),
      _readContentText(item['items']),
    ].where((text) => text.trim().isNotEmpty).toList();

    if (sections.isNotEmpty) return _cleanDisplayText(sections.join('\n\n'));

    return 'Informasi lengkap penyakit untuk level kesehatan Anda.';
  }

  String _labelContent(String label, dynamic value) {
    final text = _readContentText(value);
    if (text.isEmpty) return '';
    return '$label\n$text';
  }

  String _cleanDisplayText(String text) {
    return text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String _readFirstText(
    Map<String, dynamic> item,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = item[key];
      final text = _readContentText(value);
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  String _readContentText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num || value is bool) return value.toString();
    if (value is Iterable) {
      return value
          .map(_readContentText)
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n');
    }
    if (value is Map) {
      final title = _readContentText(
        value['heading'] ??
            value['judul'] ??
            value['title'] ??
            value['label'] ??
            value['name'] ??
            value['section_title'] ??
            value['subtitle'],
      );
      final body = _readContentText(
        value['body'] ??
            value['content'] ??
            value['konten'] ??
            value['description'] ??
            value['deskripsi'] ??
            value['summary'] ??
            value['excerpt'] ??
            value['full_content'] ??
            value['html'] ??
            value['content_html'] ??
            value['text'] ??
            value['teks'] ??
            value['isi'] ??
            value['detail'] ??
            value['keterangan'] ??
            value['pencegahan'] ??
            value['prevention'] ??
            value['pengertian'] ??
            value['definition'] ??
            value['gejala'] ??
            value['symptoms'] ??
            value['penyebab'] ??
            value['causes'] ??
            value['value'] ??
            value['items'] ??
            value['data'] ??
            value['attributes'],
      );

      if (title.isNotEmpty && body.isNotEmpty && title != body) {
        return '$title\n$body';
      }
      if (body.isNotEmpty) return body;
      return title;
    }
    return value.toString().trim();
  }

  String _extractGroup(Map<String, dynamic> item, {required String fallback}) {
    final rawParts = <String>[];
    final fields = [
      item['group'],
      item['age_group'],
      item['kategori_usia'],
      item['kelompok_usia'],
      item['usia'],
      item['umur'],
      item['age'],
      item['age_category'],
      item['ageCategory'],
      item['category_group'],
      item['kategori'],
      item['kategori_penyakit'],
      item['type'],
      item['category'],
      item['categories'],
      item['segment'],
      item['name'],
      item['nama'],
      item['title'],
      item['judul'],
    ];

    for (final value in fields) {
      final text = _readNestedText(value);
      if (text.isNotEmpty) rawParts.add(text.toLowerCase());
    }

    final raw = rawParts.join(' ');
    if (raw.contains('bayi') ||
        raw.contains('infant') ||
        raw.contains('child')) {
      return 'Bayi';
    }
    if (raw.contains('remaja') ||
        raw.contains('teen') ||
        raw.contains('youth')) {
      return 'Remaja';
    }
    if (raw.contains('dewasa') || raw.contains('adult')) {
      return 'Dewasa';
    }
    if (raw.contains('lansia') ||
        raw.contains('senior') ||
        raw.contains('elder')) {
      return 'Lansia';
    }
    return fallback;
  }

  String _readNestedText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Iterable) {
      return value
          .map(_readNestedText)
          .where((text) => text.isNotEmpty)
          .join(' ');
    }
    if (value is Map) {
      return _readNestedText(
        value['name'] ??
            value['nama'] ??
            value['title'] ??
            value['judul'] ??
            value['label'] ??
            value['slug'] ??
            value['type'],
      );
    }
    return value.toString().trim();
  }

  List<Map<String, dynamic>> get _filteredCategories {
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FBFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5FBFA),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Topik Penyakit'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildGroupFilter(),
                    const SizedBox(height: 20),
                    Expanded(child: _buildCategoryList()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D5C9E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Topik penyakit sesuai kelompok usia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _groupLabels.map((label) {
          final active = label == _selectedGroup;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(label),
              selected: active,
              selectedColor: const Color(0xFF0D5C9E),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: active ? Colors.white : const Color(0xFF0D5C9E),
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: active ? Colors.transparent : const Color(0xFFD6E6E2),
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedGroup = label;
                });
                _loadTopics();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (_filteredCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 60, color: Color(0xFF9DB7AF)),
            SizedBox(height: 14),
            Text(
              'Tidak ada topik untuk kategori ini.',
              style: TextStyle(
                color: Color(0xFF4B625B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final topic = _filteredCategories[index];
        return _buildTopicCard(topic);
      },
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final title = topic['name'] as String;
    final description = topic['description'] as String;
    final group = topic['group'] as String;

    return GestureDetector(
      onTap: () => _openTopicDetail(topic),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3F0EC)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(13, 92, 158, 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              left: 0,
              right: null,
              child: Container(width: 5, color: const Color(0xFF00A876)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_information_rounded,
                      color: Color(0xFF0D5C9E),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
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
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF14384C),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF8AA39B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF627B75),
                            fontSize: 13,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECF8F0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              group,
                              style: const TextStyle(
                                color: Color(0xFF0D5C9E),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
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
    );
  }

  Future<void> _openTopicDetail(Map<String, dynamic> topic) async {
    final title = topic['name'] as String;
    final group = topic['group'] as String;
    final raw = Map<String, dynamic>.from(
      topic['raw'] as Map<String, dynamic>? ?? const {},
    );
    var description = _readTopicContent(raw);
    if (description.trim().isEmpty ||
        description ==
            'Informasi lengkap penyakit untuk level kesehatan Anda.') {
      description = topic['description'] as String;
    }

    final slugCandidates = <String>{
      _readFirstText(raw, const [
        'slug',
        'topic_slug',
        'slug_topik',
      ], fallback: ''),
      (topic['slug'] as String?) ?? '',
      if (raw['id'] != null) raw['id'].toString(),
      _topicSlug(topic),
    }.where((value) => value.trim().isNotEmpty).toList();

    for (final slug in slugCandidates) {
      final detail = await _api.getDiseaseTopicDetail(
        categorySlug: _groupSlug(group),
        topicSlug: slug,
      );
      if (detail.isNotEmpty) {
        final merged = <String, dynamic>{...raw, ...detail};
        final detailContent = _readTopicContent(merged);
        if (detailContent.trim().isNotEmpty &&
            detailContent !=
                'Informasi lengkap penyakit untuk level kesehatan Anda.') {
          description = detailContent;
          break;
        }
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiseaseTopicDetailScreen(
          title: title,
          description: description,
          group: group,
        ),
      ),
    );
  }

  String _topicSlug(Map<String, dynamic> topic) {
    final explicitSlug = topic['slug'] as String? ?? '';
    if (explicitSlug.trim().isNotEmpty) return explicitSlug.trim();

    final title = topic['name'] as String? ?? '';
    return title
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class DiseaseTopicDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String group;

  const DiseaseTopicDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: const Color(0xFFF5FBFA),
        foregroundColor: const Color(0xFF0D5C9E),
      ),
      backgroundColor: const Color(0xFFF5FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECF8F0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        group,
                        style: const TextStyle(
                          color: Color(0xFF0D5C9E),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D5C9E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Color(0xFF516A61),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Baca dan pilih teks untuk disalin. Pastikan informasi ini menjadi referensi yang mudah digunakan saat dibuka kembali.',
                      style: TextStyle(color: Color(0xFF7A8F88), height: 1.6),
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
}
