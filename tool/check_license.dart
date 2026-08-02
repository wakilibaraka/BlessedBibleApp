// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final url = 'https://bible.helloao.org/api/available_translations.json';
  final uri = Uri.parse(url);
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.userAgentHeader, 'blessed-bible-builder/1.0');
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    final body = await resp.transform(utf8.decoder).join();
    final data = jsonDecode(body);
    final translations = data is List ? data : (data['translations'] ?? data['data'] ?? []);
    
    for (var t in translations) {
      if (t['id'] == 'HINIRV') {
        print('ID: ${t['id']}');
        print('Name: ${t['englishName']}');
        print('License URL: ${t['licenseUrl']}');
      }
    }
  } finally {
    client.close(force: false);
  }
}
