import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/services/journal_pdf_export_service.dart';

final journalPdfExportServiceProvider = Provider<JournalPdfExportService>((ref) {
  return JournalPdfExportService();
});
