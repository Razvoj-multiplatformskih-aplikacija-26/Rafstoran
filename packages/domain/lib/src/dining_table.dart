import 'package:meta/meta.dart';

import 'identifiers.dart';

enum TableArea { hall, terrace, garden }

@immutable
final class DiningTable {
  const DiningTable({required this.id, required this.label, required this.capacity, required this.area});

  final DiningTableId id;
  final String label;
  final int capacity;
  final TableArea area;

  @override
  bool operator ==(Object other) => other is DiningTable && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DiningTable($label, $capacity seats, ${area.name})';
}
