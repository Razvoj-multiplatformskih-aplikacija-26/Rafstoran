String pluralize(int count, {required String one, required String few, required String many}) {
  final lastDigit = count % 10;
  final lastTwoDigits = count % 100;
  if (lastDigit == 1 && lastTwoDigits != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) return few;
  return many;
}

String peopleLabel(int count) => '$count ${pluralize(count, one: 'osoba', few: 'osobe', many: 'osoba')}';

String slotsLabel(int count) => '$count ${pluralize(count, one: 'termin', few: 'termina', many: 'termina')}';

String freeTablesLabel(int count) =>
    '$count ${pluralize(count, one: 'slobodan sto', few: 'slobodna stola', many: 'slobodnih stolova')}';

const _weekdays = ['ponedeljak', 'utorak', 'sreda', 'četvrtak', 'petak', 'subota', 'nedelja'];
const _shortWeekdays = ['pon', 'uto', 'sre', 'čet', 'pet', 'sub', 'ned'];
const _months = [
  'januar',
  'februar',
  'mart',
  'april',
  'maj',
  'jun',
  'jul',
  'avgust',
  'septembar',
  'oktobar',
  'novembar',
  'decembar',
];

String _longDate(DateTime date) => '${_weekdays[date.weekday - 1]}, ${date.day}. ${_months[date.month - 1]}';

String _shortWeekday(DateTime date) => _shortWeekdays[date.weekday - 1];

String _dayOfMonth(DateTime date) => '${date.day}.';

String _time(DateTime date) => '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatLongDate(DateTime date) => _longDate(date);

String formatShortWeekday(DateTime date) => _shortWeekday(date);

String formatDayOfMonth(DateTime date) => _dayOfMonth(date);

String formatTime(DateTime date) => _time(date);

String formatDateAndTime(DateTime date) => '${formatLongDate(date)} u ${formatTime(date)}';

String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
