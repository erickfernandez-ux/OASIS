import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/enums/journal_emotion.dart';

class JournalPdfExportResult {
  const JournalPdfExportResult({
    required this.fileName,
    required this.filePath,
    required this.bytes,
    required this.entryCount,
  });

  final String fileName;
  final String filePath;
  final Uint8List bytes;
  final int entryCount;
}

class JournalPdfExportService {
  static const int _windowDays = 30;

  Future<JournalPdfExportResult> exportLast30Days({
    required List<JournalEntry> entries,
    required String userName,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    final periodEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final periodStart = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: _windowDays - 1));

    final entriesInRange = entries
        .where((entry) =>
            !entry.updatedAt.isBefore(periodStart) &&
            !entry.updatedAt.isAfter(periodEnd))
        .toList(growable: false)
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    final entriesByDay = _latestEntryByDay(entriesInRange);
    final monthLabel = DateFormat('yyyy-MM').format(periodEnd);
    final periodLabel =
        '${_formatDate(periodStart)} - ${_formatDate(periodEnd)}';
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(today);
    final summary = _buildSummary(entriesInRange, entriesByDay);

    final doc = pw.Document();
    final logo = await _loadLogo();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(36),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
          ),
        ),
        build: (context) => [
          _coverPage(
            logo: logo,
            userName: userName.trim().isEmpty ? 'Usuario OASIS' : userName,
            periodLabel: periodLabel,
            generatedAt: generatedAt,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Resumen general'),
          _summaryGrid(summary),
          pw.SizedBox(height: 18),
          _sectionTitle('Calendario emocional'),
          _calendarMonth(
            month: periodEnd,
            periodStart: periodStart,
            periodEnd: periodEnd,
            entriesByDay: entriesByDay,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Evolucion emocional'),
          _emotionEvolution(entriesByDay, periodStart, periodEnd),
          pw.SizedBox(height: 18),
          _sectionTitle('Gratitud'),
          _textCollection(
            entriesInRange
                .map((entry) => entry.gratitude.trim())
                .where((value) => value.isNotEmpty)
                .toList(growable: false),
            emptyMessage: 'No se registraron frases de gratitud en este periodo.',
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Aprendizajes'),
          _learningGroups(entriesInRange),
          pw.SizedBox(height: 18),
          _sectionTitle('Patrones emocionales'),
          _patternsSection(entriesInRange, entriesByDay),
        ],
      ),
    );

    if (entriesInRange.isEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(36),
            theme: pw.ThemeData.withFont(
              base: pw.Font.helvetica(),
              bold: pw.Font.helveticaBold(),
              italic: pw.Font.helveticaOblique(),
            ),
          ),
          build: (context) => [
            _sectionTitle('Registro diario'),
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFF7F2EA),
                borderRadius: pw.BorderRadius.circular(14),
              ),
              child: pw.Text(
                'No hay registros en los ultimos 30 dias. Cuando quieras, puedes volver aqui y exportar un nuevo resumen.',
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 2),
              ),
            ),
          ],
        ),
      );
    } else {
      for (final entry in entriesInRange) {
        doc.addPage(
          pw.Page(
            pageTheme: pw.PageTheme(
              margin: const pw.EdgeInsets.all(36),
              theme: pw.ThemeData.withFont(
                base: pw.Font.helvetica(),
                bold: pw.Font.helveticaBold(),
                italic: pw.Font.helveticaOblique(),
              ),
            ),
            build: (context) => _dailyEntryPage(entry),
          ),
        );
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(36),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
            italic: pw.Font.helveticaOblique(),
          ),
        ),
        build: (context) => [
          _sectionTitle('Carta para mi yo del futuro'),
          pw.Text(
            'Una seleccion de frases tuyas para recordar que avanzaste paso a paso.',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.blueGrey700),
          ),
          pw.SizedBox(height: 10),
          _futureLetter(entriesInRange),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = 'OASIS_Journal_$monthLabel.pdf';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return JournalPdfExportResult(
      fileName: fileName,
      filePath: file.path,
      bytes: bytes,
      entryCount: entriesInRange.length,
    );
  }

  Future<void> shareExportedPdf(JournalPdfExportResult result) async {
    await Printing.sharePdf(bytes: result.bytes, filename: result.fileName);
  }

  Future<pw.MemoryImage?> _loadLogo() async {
    const candidates = <String>[
      'assets/logos/oasis_logo.png',
      'assets/logos/oasis_icon.png',
    ];

    for (final path in candidates) {
      try {
        final data = await rootBundle.load(path);
        return pw.MemoryImage(data.buffer.asUint8List());
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Map<DateTime, JournalEntry> _latestEntryByDay(List<JournalEntry> entries) {
    final map = <DateTime, JournalEntry>{};
    for (final entry in entries) {
      final day = DateTime(entry.updatedAt.year, entry.updatedAt.month, entry.updatedAt.day);
      final current = map[day];
      if (current == null || entry.updatedAt.isAfter(current.updatedAt)) {
        map[day] = entry;
      }
    }
    return map;
  }

  _JournalSummary _buildSummary(
    List<JournalEntry> entries,
    Map<DateTime, JournalEntry> entriesByDay,
  ) {
    final daysRegistered = entriesByDay.length;
    final completion = (daysRegistered / _windowDays) * 100;

    final emotionCount = <JournalEmotion, int>{};
    for (final entry in entriesByDay.values) {
      emotionCount.update(entry.emotion, (count) => count + 1, ifAbsent: () => 1);
    }

    final predominant = emotionCount.entries.isEmpty
        ? null
        : emotionCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final lessFrequent = emotionCount.entries.isEmpty
        ? null
        : emotionCount.entries.reduce((a, b) => a.value <= b.value ? a : b).key;

    final avgIntensity = entriesByDay.values.isEmpty
        ? 0.0
        : entriesByDay.values
                .map((entry) => entry.intensity)
                .reduce((a, b) => a + b) /
            entriesByDay.values.length;

    final medicationDays = entriesByDay.values
        .where((entry) => entry.medicationTaken || entry.selfCareMedication)
        .length;

    final hydrationAvg = entriesByDay.values.isEmpty
        ? null
        : entriesByDay.values.where((entry) => entry.selfCareWater).length /
            entriesByDay.values.length;

    return _JournalSummary(
      daysRegistered: daysRegistered,
      completion: completion,
      predominant: predominant,
      lessFrequent: lessFrequent,
      avgIntensity: avgIntensity,
      medicationDays: medicationDays,
      hydrationAverage: hydrationAvg,
      totalEntries: entries.length,
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  pw.Widget _coverPage({
    required pw.MemoryImage? logo,
    required String userName,
    required String periodLabel,
    required String generatedAt,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(28),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF6EFE6),
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (logo != null)
            pw.Container(
              width: 64,
              height: 64,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(16),
                color: PdfColors.white,
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Resumen emocional',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF314A56),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Ultimos 30 dias',
            style: const pw.TextStyle(fontSize: 16, color: PdfColors.blueGrey700),
          ),
          pw.SizedBox(height: 20),
          _coverLine('Nombre', userName),
          _coverLine('Periodo analizado', periodLabel),
          _coverLine('Fecha de generacion', generatedAt),
        ],
      ),
    );
  }

  pw.Widget _coverLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.blueGrey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF314A56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 17,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF314A56),
        ),
      ),
    );
  }

  pw.Widget _summaryGrid(_JournalSummary summary) {
    final cards = <_SummaryCardData>[
      _SummaryCardData('Dias registrados', '${summary.daysRegistered}/30'),
      _SummaryCardData('Cumplimiento', '${summary.completion.toStringAsFixed(0)}%'),
      _SummaryCardData(
        'Emocion predominante',
        summary.predominant?.label ?? 'Sin datos',
      ),
      _SummaryCardData(
        'Emocion menos frecuente',
        summary.lessFrequent?.label ?? 'Sin datos',
      ),
      _SummaryCardData(
        'Promedio de intensidad',
        summary.avgIntensity == 0 ? 'Sin datos' : summary.avgIntensity.toStringAsFixed(1),
      ),
      _SummaryCardData('Dias con medicacion', '${summary.medicationDays}'),
      _SummaryCardData(
        'Hidratacion promedio',
        summary.hydrationAverage == null
            ? 'Sin datos'
            : '${(summary.hydrationAverage! * 100).toStringAsFixed(0)}%',
      ),
      _SummaryCardData('Registros totales', '${summary.totalEntries}'),
    ];

    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: cards
          .map(
            (item) => pw.Container(
              width: 245,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFBF7F2),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0D9CF)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.label,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey600),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    item.value,
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  pw.Widget _calendarMonth({
    required DateTime month,
    required DateTime periodStart,
    required DateTime periodEnd,
    required Map<DateTime, JournalEntry> entriesByDay,
  }) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final offset = firstDay.weekday - 1;
    final totalCells = ((offset + daysInMonth) / 7).ceil() * 7;

    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          DateFormat('MMMM yyyy', 'es').format(month),
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: labels
              .map(
                (label) => pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      label,
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        pw.SizedBox(height: 4),
        pw.Wrap(
          runSpacing: 4,
          children: List.generate(totalCells, (index) {
            final dayNum = index - offset + 1;
            final inMonth = dayNum >= 1 && dayNum <= daysInMonth;
            final day = inMonth ? DateTime(month.year, month.month, dayNum) : null;
            final inPeriod = day != null && !day.isBefore(periodStart) && !day.isAfter(periodEnd);
            final entry = day == null ? null : entriesByDay[day];
            final bg = entry == null
                ? const PdfColor.fromInt(0xFFF3F1ED)
                : _pdfEmotionColor(entry.emotion);

            return pw.Container(
              width: 72,
              height: 46,
              margin: const pw.EdgeInsets.only(right: 4),
              decoration: pw.BoxDecoration(
                color: inMonth && inPeriod ? bg : const PdfColor.fromInt(0xFFF6F4F0),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFE6DED3)),
              ),
              padding: const pw.EdgeInsets.all(6),
              child: inMonth
                  ? pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '$dayNum',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: inPeriod ? PdfColors.blueGrey900 : PdfColors.blueGrey300,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (entry != null)
                          pw.Text(
                            entry.emotion.label,
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                            style: const pw.TextStyle(fontSize: 7),
                          ),
                      ],
                    )
                  : pw.SizedBox.shrink(),
            );
          }),
        ),
      ],
    );
  }

  pw.Widget _emotionEvolution(
    Map<DateTime, JournalEntry> entriesByDay,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final values = <double>[];
    var day = periodStart;
    while (!day.isAfter(periodEnd)) {
      final key = DateTime(day.year, day.month, day.day);
      values.add(entriesByDay[key]?.intensity ?? 0);
      day = day.add(const Duration(days: 1));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Intensidad emocional dia por dia (0-5).',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFFBF7F2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: values
                .map(
                  (value) => pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                      height: math.max(8, value * 12),
                      decoration: pw.BoxDecoration(
                        color: value <= 0
                            ? const PdfColor.fromInt(0xFFE8E2DA)
                            : const PdfColor.fromInt(0xFF88A1AC),
                        borderRadius: pw.BorderRadius.circular(2),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  pw.Widget _textCollection(List<String> values, {required String emptyMessage}) {
    if (values.isEmpty) {
      return pw.Text(
        emptyMessage,
        style: const pw.TextStyle(color: PdfColors.blueGrey700),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: values
          .map(
            (value) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text('• $value'),
            ),
          )
          .toList(growable: false),
    );
  }

  pw.Widget _learningGroups(List<JournalEntry> entries) {
    final normalized = <String, int>{};
    for (final entry in entries) {
      final value = entry.learnedToday.trim();
      if (value.isEmpty) {
        continue;
      }
      normalized.update(value, (count) => count + 1, ifAbsent: () => 1);
    }

    if (normalized.isEmpty) {
      return pw.Text(
        'No se registraron aprendizajes durante este periodo.',
        style: const pw.TextStyle(color: PdfColors.blueGrey700),
      );
    }

    final sorted = normalized.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: sorted
          .map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF8F4EE),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${item.value}x',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(child: pw.Text(item.key)),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  pw.Widget _patternsSection(
    List<JournalEntry> entries,
    Map<DateTime, JournalEntry> entriesByDay,
  ) {
    if (entries.isEmpty) {
      return pw.Text(
        'Sin registros suficientes para identificar patrones aun.',
        style: const pw.TextStyle(color: PdfColors.blueGrey700),
      );
    }

    final emotionCount = <JournalEmotion, int>{};
    for (final entry in entriesByDay.values) {
      emotionCount.update(entry.emotion, (count) => count + 1, ifAbsent: () => 1);
    }
    final sortedEmotionCount = emotionCount.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    final repeated = sortedEmotionCount
        .take(3)
        .map((item) => '${item.key.label} (${item.value} dias)')
        .join(', ');

    final prodromes = <String>[];
    var anxiousStreak = 0;
    var stressStreak = 0;
    for (final entry in entries) {
      if (entry.anxiety >= 7 || entry.emotion == JournalEmotion.anxious) {
        anxiousStreak += 1;
      } else {
        anxiousStreak = 0;
      }
      if (entry.stress >= 7 && entry.irritability >= 6) {
        stressStreak += 1;
      } else {
        stressStreak = 0;
      }
      if (anxiousStreak == 2) {
        prodromes.add('En varios dias seguidos aparecio ansiedad alta.');
      }
      if (stressStreak == 2) {
        prodromes.add('Se repitio la combinacion de estres alto e irritabilidad.');
      }
    }

    final midpoint = (entries.length / 2).ceil();
    final firstHalf = entries.take(midpoint).toList(growable: false);
    final secondHalf = entries.skip(midpoint).toList(growable: false);
    final firstAvg = firstHalf.isEmpty
        ? 0.0
        : firstHalf.map((e) => e.intensity).reduce((a, b) => a + b) /
            firstHalf.length;
    final secondAvg = secondHalf.isEmpty
        ? firstAvg
        : secondHalf.map((e) => e.intensity).reduce((a, b) => a + b) /
            secondHalf.length;

    final trend = secondAvg > firstAvg
        ? 'En la segunda mitad del periodo, la intensidad promedio subio ligeramente.'
        : secondAvg < firstAvg
            ? 'En la segunda mitad del periodo, la intensidad promedio bajo con respecto al inicio.'
            : 'La intensidad promedio se mantuvo estable durante el periodo.';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _patternCard(
          'Emociones repetidas',
          repeated.isEmpty
              ? 'No hay repeticiones claras aun.'
              : 'Las emociones que mas se repitieron fueron: $repeated.',
        ),
        pw.SizedBox(height: 8),
        _patternCard(
          'Posibles prodromos detectados',
          prodromes.isEmpty
              ? 'No se observaron secuencias repetidas de alerta en este periodo.'
              : prodromes.toSet().join(' '),
        ),
        pw.SizedBox(height: 8),
        _patternCard('Tendencias observadas', trend),
      ],
    );
  }

  pw.Widget _patternCard(String title, String body) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9F5EF),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE7DFD4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(body, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
        ],
      ),
    );
  }

  pw.Widget _dailyEntryPage(JournalEntry entry) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFCF9F4),
        borderRadius: pw.BorderRadius.circular(18),
      ),
      padding: const pw.EdgeInsets.all(18),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            DateFormat('EEEE dd MMMM yyyy', 'es').format(entry.updatedAt),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF314A56),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _pill('Emocion: ${entry.emotion.label}'),
              _pill('Intensidad: ${entry.intensity.toStringAsFixed(1)}'),
              _pill('Medicación: ${(entry.medicationTaken || entry.selfCareMedication) ? 'Si' : 'No'}'),
              _pill('Hidratacion: ${entry.selfCareWater ? 'Si' : 'No'}'),
            ],
          ),
          pw.SizedBox(height: 14),
          _dailyBlock('Que ocurrio', entry.happenedToday),
          _dailyBlock('Lo mejor del dia', entry.bestPart),
          _dailyBlock('Lo mas dificil', entry.hardestPart),
          _dailyBlock('Gratitud', entry.gratitude),
          _dailyBlock('Aprendizaje', entry.learnedToday),
          _dailyBlock(
            'Autocuidado',
            _selfCareSummary(entry),
          ),
        ],
      ),
    );
  }

  pw.Widget _pill(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFE8F0F2),
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  pw.Widget _dailyBlock(String title, String value) {
    final safe = value.trim().isEmpty ? 'Sin registro.' : value.trim();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            safe,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
          ),
        ],
      ),
    );
  }

  String _selfCareSummary(JournalEntry entry) {
    final labels = <String>[];
    if (entry.selfCareWater) labels.add('Agua');
    if (entry.selfCareFood) labels.add('Comida');
    if (entry.selfCareMedication) labels.add('Medicacion');
    if (entry.selfCareMovement) labels.add('Movimiento');
    if (entry.selfCareRest) labels.add('Descanso');
    if (labels.isEmpty) {
      return 'Sin autocuidado marcado este dia.';
    }
    return labels.join(' · ');
  }

  pw.Widget _futureLetter(List<JournalEntry> entries) {
    final phrases = <String>[];

    for (final entry in entries.reversed) {
      final candidates = <String>[
        entry.bestPart.trim(),
        entry.gratitude.trim(),
        entry.learnedToday.trim(),
      ];
      for (final phrase in candidates) {
        if (phrase.length < 18) {
          continue;
        }
        if (!phrases.contains(phrase)) {
          phrases.add(phrase);
        }
      }
      if (phrases.length >= 12) {
        break;
      }
    }

    if (phrases.isEmpty) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8F3EA),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Text(
          'Aun no hay frases suficientes para esta carta. Cuando registres mas dias, esta pagina se llenara con tus palabras.',
          style: const pw.TextStyle(fontSize: 11),
        ),
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF7F0E8),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: phrases
            .map(
              (phrase) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text('"$phrase"', style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  PdfColor _pdfEmotionColor(JournalEmotion emotion) {
    return switch (emotion) {
      JournalEmotion.serene => const PdfColor.fromInt(0xFFD9E8E8),
      JournalEmotion.happy => const PdfColor.fromInt(0xFFE3EDD4),
      JournalEmotion.grateful => const PdfColor.fromInt(0xFFF0E6D5),
      JournalEmotion.hopeful => const PdfColor.fromInt(0xFFDCE8DD),
      JournalEmotion.neutral => const PdfColor.fromInt(0xFFE3E7EA),
      JournalEmotion.tired => const PdfColor.fromInt(0xFFE6DFE1),
      JournalEmotion.anxious => const PdfColor.fromInt(0xFFE7E4EE),
      JournalEmotion.sad => const PdfColor.fromInt(0xFFDDE6EF),
      JournalEmotion.frustrated => const PdfColor.fromInt(0xFFF0E0D7),
      JournalEmotion.angry => const PdfColor.fromInt(0xFFF1DCD8),
      JournalEmotion.overwhelmed => const PdfColor.fromInt(0xFFDDE6EA),
    };
  }
}

class _JournalSummary {
  const _JournalSummary({
    required this.daysRegistered,
    required this.completion,
    required this.predominant,
    required this.lessFrequent,
    required this.avgIntensity,
    required this.medicationDays,
    required this.hydrationAverage,
    required this.totalEntries,
  });

  final int daysRegistered;
  final double completion;
  final JournalEmotion? predominant;
  final JournalEmotion? lessFrequent;
  final double avgIntensity;
  final int medicationDays;
  final double? hydrationAverage;
  final int totalEntries;
}

class _SummaryCardData {
  const _SummaryCardData(this.label, this.value);

  final String label;
  final String value;
}
