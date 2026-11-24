import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

/// Base URL of the Nace Drex API. Override in tests or with a proxy.
const String naceBaseUrl = 'https://console.nace.ai';

/// Alias for the newest Drex decision model.
const String naceDefaultModel = 'drex-latest';

/// One typed question in a [NaceDrexService.evaluate] call.
sealed class NaceQuestion {
  const NaceQuestion(this.instructions);

  /// What Drex should judge about the request's state.
  final String instructions;

  Map<String, Object?> toJson();
}

/// Yes/no question. The answer is the calibrated probability of yes.
final class NaceNoulQuestion extends NaceQuestion {
  const NaceNoulQuestion(super.instructions);

  @override
  Map<String, Object?> toJson() => {
        'type': 'noul',
        'instructions': instructions,
      };
}

/// Pick one labelled option. [criteria] maps each label to what it means;
/// a `null` description leaves that option to the model.
final class NaceChoiceQuestion extends NaceQuestion {
  const NaceChoiceQuestion(super.instructions, this.criteria);

  final Map<String, String?> criteria;

  @override
  Map<String, Object?> toJson() => {
        'type': 'choice',
        'instructions': instructions,
        'criteria': criteria,
      };
}

/// Place the state on an ordered scale. [criteria] is the legend, from the
/// lowest level to the highest.
final class NaceScoreQuestion extends NaceQuestion {
  const NaceScoreQuestion(super.instructions, this.criteria);

  final List<String> criteria;

  @override
  Map<String, Object?> toJson() => {
        'type': 'score',
        'instructions': instructions,
        'criteria': criteria,
      };
}

/// One answer from Drex: the model's pick plus a calibrated probability for
/// every option it considered.
final class NaceAnswer {
  const NaceAnswer({
    required this.type,
    required this.confidence,
    this.choice,
    this.noul,
    this.score,
    this.legend = const [],
    this.probabilities = const {},
  });

  factory NaceAnswer.fromJson(Map<String, dynamic> json) {
    final probabilities = <String, double>{};
    final rawProbabilities = json['probabilities'];
    if (rawProbabilities is Map<String, dynamic>) {
      for (final entry in rawProbabilities.entries) {
        final value = entry.value;
        if (value is num) probabilities[entry.key] = value.toDouble();
      }
    }

    return NaceAnswer(
      type: json['type'] as String? ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      choice: json['choice'] as String?,
      noul: (json['noul'] as num?)?.toDouble(),
      score: (json['score'] as num?)?.toDouble(),
      legend: _parseLegend(json['legend']),
      probabilities: probabilities,
    );
  }

  /// `noul`, `choice` or `score`.
  final String type;

  /// How sure the model was overall. For a `noul` answer this is
  /// `max(noul, 1 - noul)`, so threshold the probability you act on instead.
  final double confidence;

  /// The option Drex picked for a `choice` question.
  final String? choice;

  /// Probability of yes for a `noul` question.
  final double? noul;

  /// Expected level for a `score` question.
  final double? score;

  /// Level labels for a `score` answer, lowest first.
  final List<String> legend;

  /// Calibrated probability per option (labels, or level indexes as strings).
  final Map<String, double> probabilities;

  /// Calibrated probability Drex gave [option], or `null` if it wasn't offered.
  double? probabilityOf(String option) => probabilities[option];

  /// The option with the highest probability, or `null` when there is none
  /// (a `noul` answer carries its mass in [noul] instead).
  String? get topOption {
    String? best;
    var bestProbability = -1.0;
    for (final entry in probabilities.entries) {
      if (entry.value > bestProbability) {
        best = entry.key;
        bestProbability = entry.value;
      }
    }
    return best;
  }

  /// Probability mass on [level] and every level above it, for a `score`
  /// answer. Use this rather than rounding [score] when the cost of being
  /// wrong is asymmetric.
  double probabilityAtLeast(int level) {
    var total = 0.0;
    for (final entry in probabilities.entries) {
      final index = int.tryParse(entry.key);
      if (index != null && index >= level) total += entry.value;
    }
    return total;
  }

  /// Routes on the probability of [option] (defaults to Drex's own pick).
  ///
  /// The option is taken only when its calibrated probability clears
  /// [threshold]. Otherwise the caller's [fallback] wins, so an uncertain
  /// answer is handed to a person instead of acted on.
  NaceDecision decide({
    required String fallback,
    double threshold = 0.6,
    String? option,
  }) {
    final candidate = option ?? choice ?? topOption;
    final probability =
        candidate == null ? 0.0 : (probabilities[candidate] ?? 0.0);
    if (candidate == null || probability < threshold) {
      return NaceDecision(
        option: fallback,
        probability: probability,
        threshold: threshold,
        confident: false,
      );
    }
    return NaceDecision(
      option: candidate,
      probability: probability,
      threshold: threshold,
      confident: true,
    );
  }

  /// Routes a yes/no answer: [yes] when the probability of yes clears
  /// [threshold], otherwise [no].
  NaceDecision decideYesNo({
    required String yes,
    required String no,
    double threshold = 0.5,
  }) {
    final probability = noul ?? 0.0;
    final isYes = probability >= threshold;
    return NaceDecision(
      option: isYes ? yes : no,
      probability: probability,
      threshold: threshold,
      confident: isYes,
    );
  }

  static List<String> _parseLegend(Object? raw) {
    if (raw is List<dynamic>) {
      return [for (final level in raw) level.toString()];
    }
    if (raw is Map<String, dynamic>) {
      final entries = raw.entries.toList()
        ..sort((a, b) {
          final aIndex = int.tryParse(a.key);
          final bIndex = int.tryParse(b.key);
          if (aIndex != null && bIndex != null) return aIndex.compareTo(bIndex);
          return a.key.compareTo(b.key);
        });
      return [for (final entry in entries) entry.value.toString()];
    }
    return const [];
  }
}

/// The outcome of reading an answer: either the winning option or a fallback.
final class NaceDecision {
  const NaceDecision({
    required this.option,
    required this.probability,
    required this.threshold,
    required this.confident,
  });

  /// Where to route: the winning option, or the fallback when the model's
  /// probability did not clear [threshold].
  final String option;

  /// Calibrated probability of the option the model picked.
  final double probability;

  final double threshold;

  /// Whether the model's pick cleared [threshold].
  final bool confident;
}

/// A Drex model this API key can call.
final class NaceModel {
  const NaceModel({
    required this.name,
    this.description = '',
    this.releaseDate,
    this.aliasFor,
  });

  factory NaceModel.fromJson(Map<String, dynamic> json) => NaceModel(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        releaseDate: json['release_date'] as String?,
        aliasFor: json['alias_for'] as String?,
      );

  /// Send this as `model` in a decision request; may be an alias.
  final String name;
  final String description;
  final String? releaseDate;

  /// The pinned version an alias or retired id resolves to, if any.
  final String? aliasFor;
}

/// The answers to one decision call, plus billing and tracing metadata.
final class NaceDrexResult {
  const NaceDrexResult({
    required this.answers,
    required this.requestId,
    this.model,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.evaluationTimeMs = 0,
  });

  factory NaceDrexResult.fromJson(Map<String, dynamic> json) {
    final answers = <String, NaceAnswer>{};
    final rawAnswers = json['answers'];
    if (rawAnswers is Map<String, dynamic>) {
      for (final entry in rawAnswers.entries) {
        final answer = entry.value;
        if (answer is Map<String, dynamic>) {
          answers[entry.key] = NaceAnswer.fromJson(answer);
        }
      }
    }

    var inputTokens = 0;
    var outputTokens = 0;
    final usage = json['usage'];
    if (usage is Map<String, dynamic>) {
      final input = usage['input_tokens'];
      final output = usage['output_tokens'];
      if (input is num) inputTokens = input.toInt();
      if (output is num) outputTokens = output.toInt();
    }

    final evaluationTime = json['evaluation_time_ms'];
    return NaceDrexResult(
      answers: answers,
      requestId: json['request_id'] as String? ?? '',
      model: json['model'] as String?,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      evaluationTimeMs: evaluationTime is num ? evaluationTime.toDouble() : 0,
    );
  }

  /// Answers keyed by the question id sent in the request.
  final Map<String, NaceAnswer> answers;

  /// Quote this in support requests and log it with each decision.
  final String requestId;

  /// The model that answered, when Drex reports one.
  final String? model;

  final int inputTokens;
  final int outputTokens;
  final double evaluationTimeMs;

  NaceAnswer? operator [](String questionId) => answers[questionId];
}

/// Any failed Nace call: bad key, validation error, overload or timeout.
final class NaceDrexException implements Exception {
  const NaceDrexException(
    this.message, {
    this.statusCode,
    this.type,
    this.requestId,
    this.retryAfter,
  });

  factory NaceDrexException.fromResponse(http.Response response) {
    var message = 'Drex request failed with HTTP ${response.statusCode}.';
    String? type;
    String? requestId;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        requestId = decoded['request_id'] as String?;
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          type = error['type'] as String?;
          final detail = error['message'];
          if (detail is String && detail.isNotEmpty) message = detail;
        }
      }
    } on FormatException {
      // Not the error envelope; keep the status-based message.
    }

    final retryAfterMs = int.tryParse(response.headers['retry-after-ms'] ?? '');
    return NaceDrexException(
      message,
      statusCode: response.statusCode,
      type: type,
      requestId: requestId,
      retryAfter:
          retryAfterMs == null ? null : Duration(milliseconds: retryAfterMs),
    );
  }

  final String message;
  final int? statusCode;

  /// Drex error type, such as `invalid_request_error` or `overloaded`.
  final String? type;
  final String? requestId;

  /// How long to wait before retrying, from `retry-after-ms`.
  final Duration? retryAfter;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    final id = requestId;
    final reference = id == null || id.isEmpty ? '' : ' [$id]';
    return 'NaceDrexException$status: $message$reference';
  }
}

/// Client for Nace's Drex decision API.
///
/// Send one state plus typed questions, get a calibrated probability for each
/// option, then route on it:
///
/// ```dart
/// final drex = NaceDrexService();
/// final result = await drex.evaluate(
///   state: {
///     'plan': 'chronological_1yr',
///     'day': 4,
///     'days_missed': 1,
///     'streak_days': 12,
///     'minutes_per_day': 15,
///   },
///   questions: {
///     'ease_pace': NaceNoulQuestion('Does this reader need a gentler plan?'),
///     'next_step': NaceChoiceQuestion('What should the app suggest next?', {
///       'keep_plan': 'Stay on the current plan and catch up',
///       'ease_pace': 'Recalculate the plan at an easier pace',
///       'take_break': 'Suggest a short break before resuming',
///     }),
///   },
/// );
/// final nextStep = result['next_step']!.decide(
///   fallback: 'ask_reader',
///   threshold: 0.6,
/// );
/// ```
///
/// The key comes from `NACE_API_KEY` in the environment,
/// or `--dart-define=NACE_API_KEY=...` at build time. Do not ship a key in a
/// public release build; call this from tooling or a trusted backend.
///
/// Docs: https://console.nace.ai/docs/drex/quickstart
class NaceDrexService {
  NaceDrexService({
    http.Client? client,
    String? apiKey,
    this.model = naceDefaultModel,
    String baseUrl = naceBaseUrl,
    this.timeout = const Duration(seconds: 60),
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _apiKey = apiKey == null ? apiKeyFromEnvironment() : _cleanKey(apiKey),
        _baseUrl = baseUrl;

  final http.Client _client;
  final bool _ownsClient;
  final String? _apiKey;
  final String _baseUrl;

  /// Model sent with every request unless overridden per call.
  final String model;

  /// Drex waits up to 55 seconds for the model, so allow headroom.
  final Duration timeout;

  /// Reads `NACE_API_KEY` from the process environment, falling back to a
  /// `--dart-define=NACE_API_KEY=...` compile-time value.
  static String? apiKeyFromEnvironment() {
    final fromProcess = _cleanKey(Platform.environment['NACE_API_KEY'] ?? '');
    if (fromProcess != null) return fromProcess;
    const fromDefine = String.fromEnvironment('NACE_API_KEY');
    return _cleanKey(fromDefine);
  }

  static String? _cleanKey(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Whether a key is available. The key itself is never exposed.
  bool get isConfigured => _apiKey != null;

  /// Asks Drex [questions] about [state] and returns calibrated answers.
  ///
  /// [state] may be a string or any JSON-encodable object/array. Nothing is
  /// cached or logged here; callers should not put private reader text in
  /// logs either.
  Future<NaceDrexResult> evaluate({
    required Object state,
    required Map<String, NaceQuestion> questions,
    String? model,
  }) async {
    if (questions.isEmpty) {
      throw ArgumentError.value(questions, 'questions', 'must not be empty');
    }
    final body = <String, Object?>{
      'model': model ?? this.model,
      'state': state,
      'questions': {
        for (final entry in questions.entries) entry.key: entry.value.toJson(),
      },
    };
    final response = await _send(
      () => _client.post(
        _endpoint('/v1/systemone'),
        headers: _headers(),
        body: jsonEncode(body),
      ),
    );
    return NaceDrexResult.fromJson(_decodeObject(response));
  }

  /// Lists the Drex models available to this key, including aliases.
  Future<List<NaceModel>> listModels() async {
    final response = await _send(
      () => _client.get(_endpoint('/v1/models'), headers: _headers()),
    );
    final decoded = _decodeObject(response);
    final rawModels = decoded['models'];
    if (rawModels is! List<dynamic>) {
      throw const NaceDrexException('Drex returned an unexpected model list.');
    }
    return [
      for (final model in rawModels)
        if (model is Map<String, dynamic>) NaceModel.fromJson(model),
    ];
  }

  /// Closes the HTTP client when this service created it.
  void close() {
    if (_ownsClient) _client.close();
  }

  Uri _endpoint(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers() => {
        'Authorization': 'Bearer ${_requireApiKey()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Pin the score legend to an array so parsing never depends on the
        // request's User-Agent.
        'X-Nace-Legend': 'array',
      };

  String _requireApiKey() {
    final key = _apiKey;
    if (key == null) {
      throw const NaceDrexException(
        'NACE_API_KEY is not set. Export it or pass --dart-define; see '
        '.env.example.',
      );
    }
    return key;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      throw NaceDrexException(
        'Drex did not answer within ${timeout.inSeconds}s.',
      );
    } on http.ClientException catch (error) {
      throw NaceDrexException('Could not reach Drex: ${error.message}');
    }
    if (response.statusCode != 200) {
      throw NaceDrexException.fromResponse(response);
    }
    return response;
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Fall through to the shared error below.
    }
    throw const NaceDrexException('Drex returned an unexpected response.');
  }
}
