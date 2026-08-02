// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
Future<void> main() async {
  final req = await HttpClient().getUrl(Uri.parse('https://bible.helloao.org/api/ENGWEBP/complete.json'));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  final json = jsonDecode(body);
  print('Top level keys: ${json.keys}');
  if (json['translation'] != null) {
      print('Translation keys: ${json['translation'].keys}');
  }
  if (json['books'] != null) {
    print('Books count: ${json['books'].length}');
    print('First book keys: ${json['books'][0].keys}');
    print('First book chapter 1 keys: ${json['books'][0]['chapters'][0].keys}');
  }
}
