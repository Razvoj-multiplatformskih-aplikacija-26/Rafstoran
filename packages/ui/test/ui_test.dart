import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  test('Serbian plural forms follow the number', () {
    expect(freeTablesLabel(1), '1 slobodan sto');
    expect(freeTablesLabel(3), '3 slobodna stola');
    expect(freeTablesLabel(5), '5 slobodnih stolova');
    expect(freeTablesLabel(21), '21 slobodan sto');
    expect(peopleLabel(2), '2 osobe');
    expect(peopleLabel(12), '12 osoba');
  });
}
