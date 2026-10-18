import 'package:domain/domain.dart';
import 'package:intl/intl.dart';

const serbianLatin = 'sr_Latn';

String pluralize(int count, {required String one, required String few, required String many}) {
  final lastDigit = count % 10;
  final lastTwoDigits = count % 100;
  if (lastDigit == 1 && lastTwoDigits != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) return few;
  return many;
}

String peopleLabel(int count) => '$count ${pluralize(count, one: 'osoba', few: 'osobe', many: 'osoba')}';

String hoursLabel(int count) => '$count ${pluralize(count, one: 'sat', few: 'sata', many: 'sati')}';

String seatsLabel(int count) => '$count ${pluralize(count, one: 'mesto', few: 'mesta', many: 'mesta')}';

String slotsLabel(int count) => '$count ${pluralize(count, one: 'termin', few: 'termina', many: 'termina')}';

String freeTablesLabel(int count) =>
    '$count ${pluralize(count, one: 'slobodan sto', few: 'slobodna stola', many: 'slobodnih stolova')}';

final _longDate = DateFormat('EEEE, d. MMMM', serbianLatin);
final _shortWeekday = DateFormat('EEE', serbianLatin);
final _dayOfMonth = DateFormat('d.', serbianLatin);
final _time = DateFormat('HH:mm', serbianLatin);
final _shortDate = DateFormat('EEE, d. MMM', serbianLatin);

String formatLongDate(DateTime localDate) => _longDate.format(localDate);

String formatShortWeekday(DateTime localDate) => _shortWeekday.format(localDate).replaceAll('.', '');

String formatDayOfMonth(DateTime localDate) => _dayOfMonth.format(localDate);

String formatShortDate(DateTime localDate) => capitalize(_shortDate.format(localDate).replaceAll('..', '.'));

String formatTime(DateTime instant) => _time.format(restaurantTime(instant));

String formatInstantDate(DateTime instant) => _longDate.format(restaurantTime(instant));

String formatDateAndTime(DateTime instant) => '${formatInstantDate(instant)} u ${formatTime(instant)}';

String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
