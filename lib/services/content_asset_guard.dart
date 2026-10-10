import 'dart:typed_data';

/// Thrown when a bundled content asset is not what the build expected —
/// most commonly a Git LFS *pointer file* (a ~130-byte text stub) that got
/// bundled because `git lfs pull` was never run on the build machine.
class ContentAssetException implements Exception {
  final String assetPath;
  final String message;
  const ContentAssetException(this.assetPath, this.message);

  @override
  String toString() => 'ContentAssetException($assetPath): $message';
}

/// First 16 bytes of every SQLite 3 database file.
const List<int> _sqliteMagic = [
  0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
  0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
];

/// Validates bundled SQLite bytes before they are copied to disk, so a
/// broken build fails with an actionable message instead of a cryptic
/// `file is not a database` from `PRAGMA quick_check`.
void assertBundledSqlite(String assetPath, Uint8List bytes,
    {int minBytes = 1024 * 1024}) {
  if (bytes.length >= 7 &&
      String.fromCharCodes(bytes.sublist(0, 7)) == 'version' &&
      String.fromCharCodes(
              bytes.sublist(0, bytes.length < 200 ? bytes.length : 200))
          .contains('git-lfs')) {
    throw ContentAssetException(
      assetPath,
      'bundled file is a Git LFS pointer, not a database. '
      'Run `git lfs install && git lfs pull`, then rebuild.',
    );
  }
  if (bytes.length < _sqliteMagic.length) {
    throw ContentAssetException(
        assetPath, 'bundled file is truncated (${bytes.length} bytes).');
  }
  for (var i = 0; i < _sqliteMagic.length; i++) {
    if (bytes[i] != _sqliteMagic[i]) {
      throw ContentAssetException(
          assetPath, 'bundled file is not a SQLite database.');
    }
  }
  if (bytes.length < minBytes) {
    throw ContentAssetException(assetPath,
        'bundled database is suspiciously small (${bytes.length} bytes).');
  }
}

/// Rewrites the SQLite header's file-format bytes (offsets 18/19) from WAL
/// (2) to legacy rollback journal (1) in a freshly copied, bundled database.
///
/// A WAL-mode file cannot be opened read-only unless SQLite can create its
/// `-wal`/`-shm` side files, which fails with code 14 "unable to open
/// database file". Bundled assets ship with no WAL content, so switching
/// the header is lossless; the app turns WAL back on itself when it opens
/// the database read-write. [header] must hold the file's first 20+ bytes.
void forceRollbackJournalHeader(Uint8List header) {
  if (header.length < 20) return;
  if (header[18] == 2) header[18] = 1;
  if (header[19] == 2) header[19] = 1;
}
