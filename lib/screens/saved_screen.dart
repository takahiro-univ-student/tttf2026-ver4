import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final controller = TextEditingController();
  final notes = <String>[];

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
              const Text('寄せ書き / アンケート', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: '例）店員さんが話しかけてくれて嬉しかった！\n例）雨の日のおすすめを増やしてほしい',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  final t = controller.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    notes.insert(0, t);
                    controller.clear();
                  });
                },
                icon: const Icon(Icons.send),
                label: const Text('送信'),
              ),
              const SizedBox(height: 14),
              const Text('受け取った声', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(notes[i], style: const TextStyle(height: 1.35)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}