import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/csv_loader.dart';
import '../services/openai_chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_chips.dart';

class KidsBotScreen extends StatefulWidget {
  const KidsBotScreen({super.key});

  @override
  State<KidsBotScreen> createState() => _KidsBotScreenState();
}

class _KidsBotScreenState extends State<KidsBotScreen> {
  final input = TextEditingController();
  bool busy = false;

  String mode = 'go'; // go / return
  bool tripFinished = false;

  List<Map<String, String>> quiz = [];

  final messages = <Map<String, dynamic>>[
    {'role': 'ai', 'text': 'やあ！キッズAIだよ。\n行きは説明多め、帰りはクイズで「島博士」になろう！'}
  ];

  final quick = const [
    '島ってどんなところ？',
    'おすすめの遊びは？',
    '行きモードにする',
    '帰るモードにする',
    '旅が終わった！',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    quiz = await CsvLoader.loadAsMaps('assets/data/kids_quiz.csv');
    if (mounted) setState(() {});
  }

  String _system() => [
        'あなたは子供向けの「キッズAIガイド」。',
        '口調：やさしく短く、絵文字は少し。',
        '行きモード(go)：説明多め、興味を引く。',
        '帰るモード(return)：クイズ中心、短くテンポ良く。',
        '旅が終わった(tripFinished=true)時だけ復習クイズを出す（頻出しない）。',
      ].join('\n');

  Future<void> _showQuizOnce() async {
    final pool = quiz.where((q) => (q['mode'] ?? '') == 'return').toList();
    if (pool.isEmpty || !mounted) return;

    final q = pool.first;
    final question = q['question'] ?? '';
    final a = q['choice_a'] ?? '';
    final b = q['choice_b'] ?? '';
    final c = q['choice_c'] ?? '';
    final ans = q['answer'] ?? 'choice_a';
    final explain = q['explain'] ?? '';

    final picked = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('復習クイズ'),
        content: Text('$question\n\nA: $a\nB: $b\nC: $c'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'choice_a'), child: const Text('A')),
          TextButton(onPressed: () => Navigator.pop(context, 'choice_b'), child: const Text('B')),
          TextButton(onPressed: () => Navigator.pop(context, 'choice_c'), child: const Text('C')),
        ],
      ),
    );

    final ok = picked == ans;
    setState(() {
      messages.add({
        'role': 'ai',
        'text': ok ? '正解！🎉 $explain\n\n君は今日から島博士だ！' : 'おしい！正解は ${ans.replaceAll('choice_', '').toUpperCase()}。\n$explain'
      });
    });
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || busy) return;

    if (t.contains('行きモード')) {
      setState(() {
        mode = 'go';
        messages.add({'role': 'ai', 'text': 'OK！行きモードだよ✨ 島のことを覚えよう！'});
      });
      input.clear();
      return;
    }
    if (t.contains('帰るモード')) {
      setState(() {
        mode = 'return';
        messages.add({'role': 'ai', 'text': 'OK！帰るモードだよ🧠 クイズ準備！'});
      });
      input.clear();
      return;
    }
    if (t.contains('旅が終わった')) {
      setState(() {
        tripFinished = true;
        messages.add({'role': 'ai', 'text': 'おつかれさま！最後に復習クイズを1回だけ出すね！'});
      });
      await _showQuizOnce();
      input.clear();
      return;
    }

    setState(() {
      busy = true;
      messages.add({'role': 'user', 'text': t});
    });

    final related = quiz.where((q) => (q['mode'] ?? '') == mode).take(6).toList();
    final context = related.map((q) {
      return 'Q: ${q['question']}\nA:${q['choice_a']} / B:${q['choice_b']} / C:${q['choice_c']} (ans:${q['answer']})\nex:${q['explain']}';
    }).join('\n\n');

    final reply = await OpenAiChatService.chat(
      system: _system(),
      user: t,
      context: 'mode=$mode\ntripFinished=$tripFinished\n\n【クイズ素材】\n$context',
      temperature: 0.7,
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
                  const Icon(Icons.toys, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'キッズAI（${mode == 'go' ? '行きモード' : '帰るモード'}）',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (busy)
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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
                    autofocus: true, // ← これ重要
                    enabled: true,   // ← 明示
                    textInputAction: TextInputAction.send,
                    onSubmitted: send,
                    decoration: const InputDecoration(
                      hintText: 'ここに入力…',
                    ),
                  ),
              ),
      const SizedBox(width: 10),
      FilledButton(
        onPressed: () => send(input.text),
        child: const Icon(Icons.send),
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