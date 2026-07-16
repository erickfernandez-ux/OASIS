import 'package:equatable/equatable.dart';

/// Represents unstructured knowledge capture.
/// The semantic memory of OASIS.
class Note extends Equatable {
  final String id;
  final String? title;
  final String content;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final List<String> tags;

  const Note({
    required this.id,
    this.title,
    required this.content,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.tags = const [],
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        attachments,
        createdAt,
        updatedAt,
        isFavorite,
        tags,
      ];

  @override
  String toString() => 'Note(id: $id, title: $title)';
}
