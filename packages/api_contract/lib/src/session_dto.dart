import 'json.dart';
import 'restaurant_dto.dart';

final class LoginDto {
  const LoginDto({required this.username, required this.password, this.cookie = false});

  final String username;
  final String password;
  final bool cookie;

  Map<String, Object?> toJson() => {'username': username, 'password': password, 'cookie': cookie};

  factory LoginDto.fromJson(Map<String, Object?> json) => LoginDto(
    username: jsonString(json, 'username'),
    password: jsonString(json, 'password'),
    cookie: json['cookie'] == true,
  );
}

final class SessionDto {
  const SessionDto({required this.user, required this.expiresAt, this.token});

  final UserDto user;
  final DateTime expiresAt;
  final String? token;

  Map<String, Object?> toJson() => {'user': user.toJson(), 'expiresAt': instantToJson(expiresAt), 'token': ?token};

  factory SessionDto.fromJson(Map<String, Object?> json) => SessionDto(
    user: UserDto.fromJson(jsonObject(json['user'])),
    expiresAt: jsonInstant(json, 'expiresAt'),
    token: jsonOptionalString(json, 'token'),
  );
}
