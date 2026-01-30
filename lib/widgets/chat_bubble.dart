import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final bg = isUser ? const Color(0xFF1D4ED8) : Colors.white.withOpacity(0.08);
    final border = isUser ? null : Border.all(color: Colors.white.withOpacity(0.10));
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: border,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.white.withOpacity(0.92),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}