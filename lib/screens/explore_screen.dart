import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../services/csv_loader.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool loading = true;
  List<Map<String, String>> spots = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      spots = await CsvLoader.loadAsMaps('assets/data/island_spots.csv');
    } catch (_) {
      spots = [];
    }
    if (mounted) setState(() => loading = false);
  }

  String _conversationBadge(String levelRaw) {
    final level = levelRaw.trim().toLowerCase();
    if (level == 'high' || level == 'h') return '会話◎';
    if (level == 'mid' || level == 'medium' || level == 'm') return '会話○';
    if (level == 'low' || level == 'l') return '会話△';
    return '会話？';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openMap(String? url) async {
    final u = (url ?? '').trim();
    if (u.isEmpty) {
      _toast('MAPリンクが未設定です');
      return;
    }

    final uri = Uri.tryParse(u);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      _toast('MAPリンクの形式が不正です');
      return;
    }

    try {
      final ok = await launchUrl(
        uri,
        // ✅ Web/デスクトップ/モバイル全部これが一番安定
        mode: LaunchMode.platformDefault,
        // ✅ Chrome(Web)は別タブで開く
        webOnlyWindowName: '_blank',
      );
      if (!ok) _toast('MAPを開けませんでした');
    } catch (e) {
      _toast('MAPを開けませんでした');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.background(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '島を探索',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                '会話が生まれやすい場所・島らしさを集約',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),

              // バナー
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Text(
                  '✨ あなたの意見でこのAIは進化します！',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: spots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final s = spots[i];

                          final name = (s['name'] ?? '').trim();
                          final area = (s['area'] ?? '').trim();
                          final category = (s['category'] ?? '').trim();
                          final desc = (s['description'] ?? '').trim();
                          final convo = _conversationBadge(s['conversation_level'] ?? '');
                          final mapUrl = (s['google_maps_url'] ?? '').trim();

                          return Card(
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text(
                                '$area / $category${desc.isEmpty ? '' : '\n$desc'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 会話バッジ
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                                    ),
                                    child: Text(
                                      convo,
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // MAPボタン
                                  InkWell(
                                    onTap: mapUrl.isEmpty ? null : () => _openMap(mapUrl),
                                    borderRadius: BorderRadius.circular(999),
                                    child: Opacity(
                                      opacity: mapUrl.isEmpty ? 0.5 : 1.0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.map_outlined, size: 18),
                                            SizedBox(width: 6),
                                            Text('MAP', style: TextStyle(fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}