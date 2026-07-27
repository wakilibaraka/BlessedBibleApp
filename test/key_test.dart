import 'package:flutter_test/flutter_test.dart';
import 'package:the_blessed_bible/state/user_data_provider.dart';

void main() {
  test('key test', () {
    expect(generateVerseKey('gn', 1, 1), 'GN_1:1');
  });
}
