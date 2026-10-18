import 'package:use_cases/use_cases.dart';

String failureMessage(Object? cause) => switch (cause) {
  RepositoryException(failure: RepositoryFailure.unreachable) => 'Nema veze sa serverom.',
  RepositoryException(failure: RepositoryFailure.serverError) => 'Greška na serveru.',
  _ => 'Podaci trenutno nisu dostupni.',
};
