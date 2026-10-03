import 'dart:convert';
import 'dart:io';

void main() {
  final dir = Directory('assets/devotional/stories');
  if (dir.existsSync()) {
    print("Found dir");
  } else {
    print("No dir");
  }
}
