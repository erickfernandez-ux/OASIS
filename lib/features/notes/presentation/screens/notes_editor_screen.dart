import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_controller.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteEditorScreen({this.note, super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Timer? _debounce;
  bool _isDirty = false;
  bool _isSaving = false;
  bool _showDrawPad = false;
  final List<List<Offset>> _strokes = <List<Offset>>[];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OasisScreenShell(
        title: widget.note == null ? 'Nueva nota' : 'Editar nota',
        subtitle: 'Tu cuaderno personal para escribir con calma.',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        appBarActions: [
          IconButton(
            tooltip: 'Dibujar',
            onPressed: () => setState(() => _showDrawPad = !_showDrawPad),
            icon: const Icon(Icons.draw_rounded),
          ),
          TextButton.icon(
            onPressed: _isSaving ? null : _saveNote,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Guardando' : 'Guardar'),
          ),
        ],
        scrollable: false,
        child: Column(
          children: [
            OasisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OasisTextField(
                    controller: _titleController,
                    hint: 'Titulo',
                    onChanged: (_) => _scheduleSave(),
                  ),
                  const SizedBox(height: OasisSpacing.sm),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveNote,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
                      ),
                      const SizedBox(width: OasisSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showDrawPad = !_showDrawPad),
                        icon: const Icon(Icons.draw_rounded),
                        label: Text(_showDrawPad ? 'Ocultar dibujo' : 'Dibujar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: OasisSpacing.md),
            Expanded(
              child: _NotebookPaper(
                child: OasisMultilineField(
                  controller: _contentController,
                  hint: 'Escribe aqui...',
                  onChanged: (_) => _scheduleSave(),
                  expands: true,
                  minLines: 1,
                  maxLines: null,
                ),
              ),
            ),
            AnimatedSize(
              duration: MotionSpec.selectionFade,
              curve: MotionSpec.easeInOut,
              child: _showDrawPad
                  ? Padding(
                      padding: const EdgeInsets.only(top: OasisSpacing.md),
                      child: _buildDrawPad(context),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleSave() {
    _isDirty = true;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _saveNote();
      }
    });
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    if (!_isDirty && _titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    final note = Note(
      id: widget.note?.id ?? '',
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: widget.note?.updatedAt ?? DateTime.now(),
      isFavorite: widget.note?.isFavorite ?? false,
      tags: widget.note?.tags ?? const [],
    );

    try {
      // Future feedback cues: haptic notes.save and sound save.
      await ref.read(notesControllerProvider.notifier).saveNote(note);
      if (mounted) {
        setState(() => _isDirty = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildDrawPad(BuildContext context) {
    return OasisCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dibujo rapido',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Limpiar',
                onPressed: () => setState(_strokes.clear),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: OasisSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _strokes.add([details.localPosition]));
              },
              onPanUpdate: (details) {
                if (_strokes.isEmpty) return;
                setState(() => _strokes.last.add(details.localPosition));
              },
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: CustomPaint(
                  painter: _DrawPadPainter(strokes: _strokes),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookPaper extends StatelessWidget {
  const _NotebookPaper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OasisCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _NotebookLinesPainter(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
            child: Padding(
              padding: const EdgeInsets.all(OasisSpacing.md),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFFFFCF6);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFE2D8C8)
      ..strokeWidth = 1;

    for (double y = 26; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginPaint = Paint()
      ..color = const Color(0xFFF0B7A4)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(32, 0), Offset(32, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DrawPadPainter extends CustomPainter {
  const _DrawPadPainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF8F3EA),
    );

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFD7C9B2)
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, border);

    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF3F3B35);

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, pen);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawPadPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
