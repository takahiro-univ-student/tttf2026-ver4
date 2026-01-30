import 'package:flutter/services.dart' show rootBundle;

class CsvLoader {
  /// CSV(クォート対応)を読み、1行目をヘッダーとして Map 化する
  static Future<List<Map<String, String>>> loadAsMaps(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);

    final lines = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    final header = _splitCsvLine(lines.first).map((s) => s.trim()).toList();
    final out = <Map<String, String>>[];

    for (int i = 1; i < lines.length; i++) {
      final cols = _splitCsvLine(lines[i]);
      final m = <String, String>{};

      for (int j = 0; j < header.length; j++) {
        final key = header[j];
        final val = (j < cols.length ? cols[j] : '').trim();
        m[key] = val;
      }
      out.add(m);
    }
    return out;
  }

  /// ✅ クォート対応 CSV 1行パーサ
  /// - "a,b" みたいなカンマを含むセルを壊さない
  /// - "" は " として扱う
  static List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final sb = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];

      if (ch == '"') {
        // エスケープされたダブルクォート ""
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          sb.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (ch == ',' && !inQuotes) {
        result.add(sb.toString());
        sb.clear();
        continue;
      }

      sb.write(ch);
    }
    result.add(sb.toString());
    return result;
  }

  /// 軽量検索：クエリに近い行を上位k件返す
  static List<Map<String, String>> topK(List<Map<String, String>> rows, String q, {int k = 6}) {
    final qq = q.toLowerCase();

    int score(Map<String, String> r) {
      final all = r.values.join(' ').toLowerCase();
      int s = 0;

      for (final token in qq.split(RegExp(r'\s+')).where((e) => e.isNotEmpty)) {
        if (all.contains(token)) s += 2;
      }

      // 会話/つながり系なら conversation_level を加点
      if (qq.contains('会話') || qq.contains('つながり') || qq.contains('交流')) {
        final lv = (r['conversation_level'] ?? '').toLowerCase();
        if (lv == 'high' || lv == 'h') s += 4;
        if (lv == 'mid' || lv == 'medium' || lv == 'm') s += 2;
      }

      // MAP があるスポットは少し加点
      if ((r['google_maps_url'] ?? '').trim().isNotEmpty) s += 1;

      return s;
    }

    final sorted = [...rows]..sort((a, b) => score(b).compareTo(score(a)));
    return sorted.take(k).toList();
  }

  /// ChatGPTに渡す用（短く整形）
  static String contextText(List<Map<String, String>> rows, {int max = 6}) {
    final take = rows.take(max).toList();
    final b = StringBuffer();

    for (final r in take) {
      final name = r['name'] ?? '';
      final area = r['area'] ?? '';
      final cat = r['category'] ?? '';
      final lv = r['conversation_level'] ?? '';
      final desc = r['description'] ?? '';
      final notes = r['notes'] ?? '';
      final map = r['google_maps_url'] ?? '';

      b.writeln('- $name ($area / $cat) conversation_level=$lv');
      if (desc.isNotEmpty) b.writeln('  description: $desc');
      if (notes.isNotEmpty) b.writeln('  notes: $notes');
      if (map.isNotEmpty) b.writeln('  map: $map');
    }
    return b.toString();
  }

  /// JSONにして渡したい時用（あなたのIslandBotScreen側で使ってるなら便利）
  static String toPrettyJson(Map<String, dynamic> obj) {
    // dart:convert を使わずに済むなら不要だが、使うなら import dart:convert; してOK
    // ここでは簡易で返す（必要なら削ってもOK）
    return obj.toString();
  }
}