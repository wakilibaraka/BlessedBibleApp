import 'dart:io';
// ignore_for_file: avoid_print
import 'dart:convert';

Future<void> main() async {
  final url = 'https://ebible.org/Scriptures/details.php?id=hin2017';
  final uri = Uri.parse(url);
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0');
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    final html = await resp.transform(utf8.decoder).join();
    
    final htmlLower = html.toLowerCase();
    
    final keywords = ['public domain', 'creative commons', 'cc0', 'cc by', 'copyright', 'all rights reserved', 'open access'];
    
    for (var keyword in keywords) {
      final idx = htmlLower.indexOf(keyword);
      if (idx != -1) {
        final start = idx - 20 < 0 ? 0 : idx - 20;
        final end = idx + 80 > html.length ? html.length : idx + 80;
        final snippet = html.substring(start, end).replaceAll('\n', '').replaceAll('\r', '').trim();
        print('Keyword found: $keyword');
        print('Snippet: $snippet');
        break;
      }
    }
  } finally {
    client.close(force: false);
  }
}
