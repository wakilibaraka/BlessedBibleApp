// Smoke-check the Nace Drex integration against the live API.
//
//   export NACE_API_KEY="nace_sk_..."
//   dart run tool/nace_smoke.dart
//
// Lists the Drex models this key can use, then asks one yes/no and one choice
// question about a sample reading-plan case. Prints the calibrated
// probabilities and the route each decision takes. Never prints the key.
import 'dart:io';

import 'package:the_blessed_bible/services/nace_drex_service.dart';

Future<void> main() async {
  final drex = NaceDrexService();
  if (!drex.isConfigured) {
    stderr.writeln('NACE_API_KEY is not set. See .env.example.');
    exitCode = 1;
    return;
  }

  try {
    final models = await drex.listModels();
    print('Models: ${models.map((model) => model.name).join(', ')}');

    final result = await drex.evaluate(
      state: {
        'plan': 'chronological_1yr',
        'day': 4,
        'days_completed': 3,
        'days_missed': 1,
        'streak_days': 12,
        'minutes_per_day': 15,
        'notes':
            'The genealogies feel long, but the reader wants to keep going.',
      },
      questions: const {
        'needs_gentler_pace':
            NaceNoulQuestion('Does this reader need a gentler pace?'),
        'next_step': NaceChoiceQuestion('What should the app suggest next?', {
          'keep_plan': 'Stay on the current plan and catch up',
          'ease_pace': 'Recalculate the plan at an easier pace',
          'switch_plan': 'Offer a shorter topical plan',
          'take_break': 'Suggest a short break before resuming',
        }),
      },
    );

    print('request_id: ${result.requestId}');
    print('model: ${result.model ?? drex.model}');
    print('tokens: ${result.inputTokens} in / ${result.outputTokens} out');

    final ease = result['needs_gentler_pace'];
    if (ease != null && ease.noul != null) {
      final route = ease.decideYesNo(yes: 'ease', no: 'keep');
      print('P(gentler pace) = ${ease.noul!.toStringAsFixed(4)} '
          '-> ${route.option}');
    }

    final next = result['next_step'];
    if (next != null) {
      for (final entry in next.probabilities.entries) {
        print('  ${entry.key}: ${entry.value.toStringAsFixed(4)}');
      }
      final route = next.decide(fallback: 'ask_reader', threshold: 0.6);
      print('route: ${route.option} '
          '(p=${route.probability.toStringAsFixed(4)}, '
          'confident=${route.confident})');
    }
  } on NaceDrexException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  } finally {
    drex.close();
  }
}
