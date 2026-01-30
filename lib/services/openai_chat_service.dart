import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAiChatService {
  static String get _key => const String.fromEnvironment('OPENAI_API_KEY');
  static bool get hasKey => _key.isNotEmpty;

  static Future<String> chat({
    required String system,
    required String user,
    required String context,
    String model = 'gpt-4o-mini',
    double temperature = 0.6,
  }) async {
    if (!hasKey) {
      return 'APIキーが設定されていません。\n'
          'macOSでの実行例：\n'
          'OPENAI_API_KEY="sk-..." flutter run -d macos';
    }

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = {
      'model': model,
      'temperature': temperature,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': '【島のローカル情報】\n$context\n\n【質問】\n$user'},
      ],
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode >= 400) {
        return 'サーバエラー(${res.statusCode}): ${res.body}';
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (json['choices'] as List).first['message']['content'] as String?;
      return (content ?? '').trim().isEmpty ? '返答が空でした。' : content!.trim();
    } catch (e) {
      return '通信エラー: $e\n※Web実行は環境により失敗しがち。macOSで実行してね。';
    }
  }
}