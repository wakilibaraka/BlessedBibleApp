class TranslationInfo {
  final String translationId;
  final String languageCode;
  final String languageName;
  final String translationName;
  final String abbreviation;
  final String license;
  final bool isComplete;
  final bool isDownloaded;

  TranslationInfo({
    required this.translationId,
    required this.languageCode,
    required this.languageName,
    required this.translationName,
    required this.abbreviation,
    required this.license,
    required this.isComplete,
    this.isDownloaded = false,
  });

  factory TranslationInfo.fromMap(Map<String, dynamic> map) {
    return TranslationInfo(
      translationId: map['translation_id'] as String,
      languageCode: map['language_code'] as String,
      languageName: map['language_name'] as String,
      translationName: map['translation_name'] as String,
      abbreviation: map['abbreviation'] as String,
      license: map['license'] as String,
      isComplete: (map['is_complete'] as int? ?? 0) == 1,
      isDownloaded: (map['is_downloaded'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'translation_id': translationId,
      'language_code': languageCode,
      'language_name': languageName,
      'translation_name': translationName,
      'abbreviation': abbreviation,
      'license': license,
      'is_complete': isComplete ? 1 : 0,
      'is_downloaded': isDownloaded ? 1 : 0,
    };
  }
}
