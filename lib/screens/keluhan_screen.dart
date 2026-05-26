import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class KeluhanScreen extends StatefulWidget {
  const KeluhanScreen({super.key});

  @override
  State<KeluhanScreen> createState() => _KeluhanScreenState();
}

class _KeluhanScreenState extends State<KeluhanScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _pickedImagePath;
  List<dynamic> _keluhan = [];
  final Set<String> _deletingKeluhanIds = {};

  @override
  void initState() {
    super.initState();
    _loadKeluhan();
  }

  Future<void> _loadKeluhan() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _api.getKeluhan();
    setState(() {
      _keluhan = data;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _pickedImagePath = picked.path;
    });
  }

  Future<void> _submitKeluhan() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detail keluhan tidak boleh kosong.')),
      );
      return;
    }

    final title = description.length > 30
        ? '${description.substring(0, 30).trim()}...'
        : description;

    setState(() {
      _isSubmitting = true;
    });

    final result = await _api.createKeluhan(title, description);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if ((result['success'] == true) || result['message'] == 'created') {
      _descriptionController.clear();
      _pickedImagePath = null;
      await _loadKeluhan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan berhasil dikirim.')),
      );
    } else {
      final message = result['message'] ?? 'Gagal mengirim keluhan.';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F8F6),
        foregroundColor: const Color(0xFF1F6E47),
        title: const Text('Keluhan Pasien'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroPanel(),
              const SizedBox(height: 14),
              _buildComposerCard(),
              const SizedBox(height: 14),
              _buildTrustNote(),
              const SizedBox(height: 24),
              _buildHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteKeluhan(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data keluhan ini belum memiliki ID.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus keluhan?'),
          content: const Text(
            'Data keluhan akan dihapus dari riwayat. Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _deleteKeluhan(id);
  }

  Future<void> _deleteKeluhan(dynamic id) async {
    final idText = id.toString();
    setState(() {
      _deletingKeluhanIds.add(idText);
    });

    final result = await _api.deleteKeluhan(id);
    if (!mounted) return;

    final success =
        result['success'] == true ||
        result['message'] == 'deleted' ||
        result['message'] == 'success';

    setState(() {
      _deletingKeluhanIds.remove(idText);
    });

    if (success) {
      await _loadKeluhan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan berhasil dihapus.')),
      );
    } else {
      final message = result['message'] ?? 'Gagal menghapus keluhan.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildIntroPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D5C9E), Color(0xFF00A876)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D5C9E).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 34),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsultasi Keluhan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tulis gejala yang Anda rasakan agar tim dapat meninjau dengan jelas.',
                  style: TextStyle(
                    color: Color(0xFFE3F7F2),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1EEE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            label: 'Detail Keluhan',
            hint: 'Contoh: demam sejak dua hari, batuk, dan pusing...',
            controller: _descriptionController,
            minLines: 5,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              _pickedImagePath == null
                  ? 'Lampirkan foto opsional'
                  : _pickedImagePath!.split(RegExp(r'[/\\]')).last,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D5C9E),
              side: const BorderSide(color: Color(0xFFB8DAD2)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5C9E),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitKeluhan,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white),
            label: Text(
              _isSubmitting ? 'Mengirim...' : 'Kirim Keluhan',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5ECE3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFF1F6E47)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Data keluhan Anda tersimpan aman dan hanya digunakan untuk proses layanan.',
              style: TextStyle(color: Color(0xFF46645A), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Riwayat Keluhan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF14384C),
                ),
              ),
            ),
            IconButton(
              onPressed: _loadKeluhan,
              icon: const Icon(Icons.refresh_rounded),
              color: const Color(0xFF0D5C9E),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_keluhan.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1EEE8)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 42,
                  color: Color(0xFF8AA39B),
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada keluhan yang dikirim.',
                  style: TextStyle(
                    color: Color(0xFF627B75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else
          ..._keluhan.map((item) {
            if (item is! Map) return const SizedBox.shrink();
            final keluhan = Map<String, dynamic>.from(item);
            final status = _extractString(
              keluhan['status'] ?? keluhan['state'] ?? 'Menunggu',
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildHistoryCard(keluhan, status),
            );
          }),
      ],
    );
  }

  String _extractString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is Map) {
      return _extractString(
        value['name'] ?? value['title'] ?? value['label'] ?? value['text'],
        fallback,
      );
    }
    return value.toString();
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF425255),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4FCF8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E9DE)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            minLines: minLines,
            maxLines: minLines > 1 ? null : 1,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, String status) {
    final id = item['id'];
    final title = item['title'] ?? 'Keluhan kesehatan';
    final description = item['description'] ?? '-';
    final response = item['response'] ?? 'Belum ada respon.';
    final createdAt = item['created_at'] ?? item['date'] ?? '';
    final isAnswered = status.toLowerCase() == 'dijawab';
    final isDeleting =
        id != null && _deletingKeluhanIds.contains(id.toString());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18),
        ],
      ),
      child: Padding(
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
                      color: Color(0xFF1F6E47),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAnswered
                            ? const Color(0xFFEAF7EE)
                            : const Color(0xFFFFF5E7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: isAnswered
                              ? const Color(0xFF1F6E47)
                              : const Color(0xFFB16000),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isDeleting
                          ? null
                          : () => _confirmDeleteKeluhan(item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE74C3C),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Color(0xFFE74C3C),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: Color(0xFFE74C3C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: const TextStyle(color: Color(0xFF5F6F69), height: 1.5),
            ),
            if (createdAt.toString().isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFF9DB7AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    createdAt.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9DB7AF),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FBF0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jawaban Dokter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F6E47),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    response,
                    style: const TextStyle(
                      color: Color(0xFF4E655D),
                      height: 1.5,
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
}
