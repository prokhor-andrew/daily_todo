class Note {
  final String id;
  final String contents;
  final DateTime date;
  final bool done;

  Note({
    required this.id,
    required this.contents,
    required this.date,
    required this.done,
  });

  @override
  String toString() {
    return "id: $id, contents: $contents, date: $date";
  }
}

List<Note> noteMapToNoteList(Object? data) {
  return (data as List<Object?>? ?? []).map((value) {

    final Map<Object?, Object?> map = value as Map<Object?, Object?>;
    final String contents = map['contents'] as String;
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int);
    final bool done = map['done'] as bool;
    final String id = map['id'] as String;

    return Note(id: id, contents: contents, date: date, done: done);
  }).toList();
}
