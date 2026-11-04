import 'package:meta/meta.dart';

import 'identifiers.dart';

enum Role {
  guest,
  waiter,
  manager;

  bool get isStaff => this != Role.guest;
}

@immutable
final class User {
  const User({required this.id, required this.name, required this.role});

  final UserId id;
  final String name;
  final Role role;

  @override
  bool operator ==(Object other) => other is User && other.id == id && other.name == name && other.role == role;

  @override
  int get hashCode => Object.hash(id, name, role);

  @override
  String toString() => 'User($name, ${role.name})';
}
