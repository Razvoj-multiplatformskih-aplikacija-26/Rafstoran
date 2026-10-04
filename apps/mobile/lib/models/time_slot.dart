class TimeSlot {
  const TimeSlot({required this.start, required this.freeTables});

  static const duration = Duration(hours: 2);

  final DateTime start;
  final int freeTables;

  DateTime get end => start.add(duration);
  bool get isAvailable => freeTables > 0;
  String get id => start.toIso8601String();
}
