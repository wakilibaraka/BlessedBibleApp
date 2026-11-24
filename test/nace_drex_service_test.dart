import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:the_blessed_bible/services/nace_drex_service.dart';

http.Response _json(Object body, [int statusCode = 200]) => http.Response(
      jsonEncode(body),
      statusCode,
      headers: const {'content-type': 'application/json'},
    );

void main() {
  test('evaluate sends state and typed questions, then routes on probability',
      () async {
    late http.Request seen;
    late Map<String, dynamic> body;
    final client = MockClient((request) async {
      seen = request;
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({
        'model': 'drex-v2.0',
        'answers': {
          'needs_gentler_pace': {
            'type': 'noul',
            'noul': 0.81,
            'confidence': 0.81,
          },
          'next_step': {
            'type': 'choice',
            'choice': 'ease_pace',
            'confidence': 0.72,
            'probabilities': {
              'keep_plan': 0.12,
              'ease_pace': 0.68,
              'take_break': 0.2,
            },
          },
        },
        'usage': {'input_tokens': 40, 'output_tokens': 12},
        'evaluation_time_ms': 9.4,
        'request_id': 'req_9d4e1b2c7a3f4e0d8b6c5a4f3e2d1c0b',
      });
    });
    final drex = NaceDrexService(client: client, apiKey: 'nace_sk_test');

    final result = await drex.evaluate(
      state: 'Day 4 of 30 missed; 12-day streak before that.',
      questions: const {
        'needs_gentler_pace':
            NaceNoulQuestion('Does this reader need a gentler pace?'),
        'next_step': NaceChoiceQuestion('What should the app suggest next?', {
          'keep_plan': 'Stay on the current plan and catch up',
          'ease_pace': 'Recalculate the plan at an easier pace',
          'take_break': 'Suggest a short break before resuming',
        }),
      },
    );

    expect(seen.method, 'POST');
    expect(seen.url.toString(), 'https://console.nace.ai/v1/systemone');
    expect(seen.headers['Authorization'], 'Bearer nace_sk_test');
    expect(body['model'], 'drex-latest');
    expect(body['state'], 'Day 4 of 30 missed; 12-day streak before that.');
    final questions = body['questions'] as Map<String, dynamic>;
    final noul = questions['needs_gentler_pace'] as Map<String, dynamic>;
    expect(noul['type'], 'noul');
    expect(noul['instructions'], 'Does this reader need a gentler pace?');
    final choice = questions['next_step'] as Map<String, dynamic>;
    expect(choice['type'], 'choice');
    expect(
      choice['criteria'],
      containsPair('ease_pace', 'Recalculate the plan at an easier pace'),
    );

    final nextStep = result['next_step']!;
    expect(nextStep.choice, 'ease_pace');
    expect(nextStep.probabilityOf('ease_pace'), 0.68);
    expect(nextStep.topOption, 'ease_pace');
    expect(
      nextStep.decide(fallback: 'ask_reader', threshold: 0.6).option,
      'ease_pace',
    );
    expect(
      nextStep.decide(fallback: 'ask_reader', threshold: 0.8).option,
      'ask_reader',
    );
    expect(
      result['needs_gentler_pace']!.decideYesNo(yes: 'ease', no: 'keep').option,
      'ease',
    );
    expect(result.requestId, 'req_9d4e1b2c7a3f4e0d8b6c5a4f3e2d1c0b');
    expect(result.model, 'drex-v2.0');
    expect(result.inputTokens, 40);
    expect(result.outputTokens, 12);
    expect(result.evaluationTimeMs, 9.4);
  });

  test('listModels requests the Drex catalogue', () async {
    late http.Request seen;
    final drex = NaceDrexService(
      apiKey: 'nace_sk_test',
      client: MockClient((request) async {
        seen = request;
        return _json({
          'models': [
            {
              'name': 'drex-latest',
              'description': 'Alias of the newest Drex model',
              'release_date': '2026-10-06',
              'alias_for': 'drex-v2.0',
            },
            {
              'name': 'drex-v2.0',
              'description': 'Drex 2.0 decision model',
              'release_date': '2026-10-06',
              'alias_for': null,
            },
          ],
          'request_id': 'req_0123456789abcdef0123456789abcdef',
        });
      }),
    );

    final models = await drex.listModels();

    expect(seen.method, 'GET');
    expect(seen.url.toString(), 'https://console.nace.ai/v1/models');
    expect(seen.headers['Authorization'], 'Bearer nace_sk_test');
    expect(models.map((m) => m.name), ['drex-latest', 'drex-v2.0']);
    expect(models.first.aliasFor, 'drex-v2.0');
    expect(models.last.aliasFor, isNull);
  });

  test('score answers keep probabilities by level', () {
    final answer = NaceAnswer.fromJson({
      'type': 'score',
      'score': 1.5306,
      'legend': {'0': 'Calm', '1': 'Mildly annoyed', '2': 'Frustrated'},
      'probabilities': {'0': 0.1572, '1': 0.3516, '2': 0.4912},
      'confidence': 0.7183,
    });

    expect(answer.legend, ['Calm', 'Mildly annoyed', 'Frustrated']);
    expect(answer.probabilityAtLeast(2), closeTo(0.4912, 1e-9));
    expect(answer.topOption, '2');
  });

  test('missing key fails before any request', () async {
    var called = false;
    final drex = NaceDrexService(
      apiKey: '',
      client: MockClient((_) async {
        called = true;
        return _json({});
      }),
    );

    expect(drex.isConfigured, isFalse);
    await expectLater(
      drex.evaluate(
        state: 'Day 4 of 30 missed.',
        questions: const {'q': NaceNoulQuestion('Is this urgent?')},
      ),
      throwsA(isA<NaceDrexException>()),
    );
    expect(called, isFalse);
  });

  test('surfaces API errors with the request id', () async {
    final drex = NaceDrexService(
      apiKey: 'nace_sk_test',
      client: MockClient((_) async => _json({
            'error': {
              'type': 'invalid_request_error',
              'message': 'questions: must not be empty',
            },
            'request_id': 'req_bd2dffad68f5f5fa4ce702e9bd516fb4',
          }, 422)),
    );

    await expectLater(
      drex.evaluate(
        state: 'Day 4 of 30 missed.',
        questions: const {'q': NaceNoulQuestion('Is this urgent?')},
      ),
      throwsA(
        isA<NaceDrexException>()
            .having((e) => e.statusCode, 'statusCode', 422)
            .having((e) => e.type, 'type', 'invalid_request_error')
            .having((e) => e.requestId, 'requestId',
                'req_bd2dffad68f5f5fa4ce702e9bd516fb4'),
      ),
    );
  });
}
