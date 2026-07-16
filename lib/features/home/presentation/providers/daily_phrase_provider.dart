import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_message_system_provider.dart';

final dailyPhraseProvider = Provider<String>((ref) {
  return ref.watch(appMessageSystemProvider).dailyMessageFor(DateTime.now());
});
