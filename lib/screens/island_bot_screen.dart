import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/csv_loader.dart';
import '../services/openai_chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_chips.dart';

class IslandBotScreen extends StatefulWidget {
  const IslandBotScreen({super.key});

  @override
  State<IslandBotScreen> createState() => _IslandBotScreenState();
}

class _IslandBotScreenState extends State<IslandBotScreen> {
  final input = TextEditingController();
  bool busy = false;

  final messages = <Map<String, dynamic>>[
    {
      'role': 'ai',
      'text': 'こんにちは！島ナビAIです。\n'
          '「今日やってるイベント」「今開いてそうなお店」「移動手段（バス/自転車）」など聞いてください。'
    }
  ];

  List<Map<String, String>> spots = [];
  List<Map<String, String>> events = [];

  final quick = const [
    '今日のイベント教えて',
    '今おすすめのご飯屋さん',
    '会話が生まれやすい場所ある？',
    '雨の日でも楽しめる？',
    '移動手段を提案して（バス/自転車）',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    spots = await CsvLoader.loadAsMaps('assets/data/island_spots.csv');
    events = await CsvLoader.loadAsMaps('assets/data/events.csv');
    if (mounted) setState(() {});
  }

  String _system() => [
        'あなたは「島ナビAI」。観光客に、今日役立つ情報を短くわかりやすく提案する。',
        '必ず守る：',
        '1) 店の営業は変動する前提で断定しすぎない（最後に注意書き）。',
        '2) 「定番/よく開いている」候補を優先。',
        '3) イベントは見落とさず、期間/場所/ポイントを短く。',
        '4) 島らしさ（地元の雰囲気・会話が生まれやすい場所）を反映。',
        '5) 出力は長すぎない。箇条書き中心。',
      ].join('\n');

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || busy) return;

    setState(() {
      busy = true;
      messages.add({'role': 'user', 'text': t});
    });

    final relSpots = CsvLoader.topK(spots, t, k: 6);
    final relEvents = CsvLoader.topK(events, t, k: 6);

    final context = [
      '【スポット候補】',
      CsvLoader.contextText(relSpots),
      '',
      '【イベント候補】',
      CsvLoader.contextText(relEvents),
      '',
      '【注意】不定休/臨時休業あり。SNSや当日ストーリー確認推奨。',
    ].join('\n');

    final reply = await OpenAiChatService.chat(
      system: _system(),
      user: t,
      context: context,
      temperature: 0.6,
      model: 'gpt-4o-mini',
    );

    setState(() {
      messages.add({'role': 'ai', 'text': reply});
      busy = false;
      input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.background(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Icon(Icons.travel_explore),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('島ナビAI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('イベント・店・島らしさを提案', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  if (!OpenAiChatService.hasKey)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.red.withOpacity(0.35)),
                      ),
                      child: const Text('API未設定', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  if (busy) ...[
                    const SizedBox(width: 10),
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  return ChatBubble(text: m['text'], isUser: m['role'] == 'user');
                },
              ),
            ),
            if (!busy)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: QuickChips(chips: quick, onTap: send),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      onSubmitted: send,
                      decoration: const InputDecoration(
                        hintText: '例：今日のイベントは？ / 会話が生まれやすい場所は？',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(onPressed: () => send(input.text), child: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}