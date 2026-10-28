import '../data/local_system.dart';
import '../data/scenarios.dart';
import 'labels.dart';

final class DemoStep {
  const DemoStep({required this.scenario, required this.title, required this.detail, required this.explanation});

  final Scenario scenario;
  final String title;
  final String detail;
  final String explanation;
}

List<DemoStep> demoSteps({required int noteLength}) => [
  const DemoStep(
    scenario: HealthCheck(),
    title: 'Server radi?',
    detail: 'GET /health',
    explanation: 'Server odgovara „ok“ čim je pokrenut. Tako se vidi i da je konzola pronašla server.',
  ),
  const DemoStep(
    scenario: TomorrowSlots(),
    title: 'Termini za sutra',
    detail: 'GET /api/v1/slots',
    explanation:
        'Slobodne termine računa funkcija availableSlots iz paketa domain, ista koju koristi aplikacija. '
        'Odgovor je lista SlotDto iz paketa api_contract.',
  ),
  const DemoStep(
    scenario: NewReservation(),
    title: 'Nova rezervacija',
    detail: 'POST /api/v1/reservations',
    explanation:
        'Rukovalac poziva isti use case CreateReservation kao aplikacija, a PostgresRestaurant upisuje red u bazu. '
        'U Adminer-u se posle osvežavanja vidi novi red u tabeli reservations.',
  ),
  DemoStep(
    scenario: LongNote(noteLength),
    title: noteLabel(noteLength),
    detail: 'POST /api/v1/reservations',
    explanation:
        'Poziv mimo aplikacije. Server proverava napomenu istim ReservationNote.parse iz domena i vraća 422 sa '
        'kodom note-too-long. Konzola od koda pravi poruku preko api_mapping i ui, kao aplikacija; u bazi nema '
        'novog reda.',
  ),
  const DemoStep(
    scenario: LocalStep(LocalTask.rebuildServer),
    title: 'Izgradi server ponovo',
    detail: 'docker compose up -d --build server',
    explanation:
        'Izmena uživo: u packages/domain/lib/src/reservation/reservation_note.dart postavite maxLength na 100, '
        'pa izgradite server. Posle toga napomena od 101 znaka daje 422 sa max 100.',
  ),
];

const toolSteps = [
  DemoStep(
    scenario: LocalStep(LocalTask.startAdminer),
    title: 'Adminer',
    detail: 'docker compose --profile tools up -d adminer',
    explanation:
        'Pregled baze u pregledaču, već prijavljen, na tabeli reservations. Posle svakog koraka osvežite stranicu.',
  ),
  DemoStep(
    scenario: LocalStep(LocalTask.reset),
    title: 'Reset podataka',
    detail: 'docker compose down -v, pa up -d',
    explanation: 'Baza od nule, kao iz čistog klona, sa početnim podacima.',
  ),
];

DemoStep stepOf(Scenario scenario) {
  final noteLength = switch (scenario) {
    LongNote(:final length) => length,
    _ => 0,
  };
  return [...demoSteps(noteLength: noteLength), ...toolSteps].firstWhere((step) => step.scenario == scenario);
}
