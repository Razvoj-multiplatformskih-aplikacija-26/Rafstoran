// Ready for copy as is.
import 'dart:convert';
import 'dart:isolate';

import 'package:hashlib/hashlib.dart';
import 'package:hashlib/random.dart';

Future<String> hashPassword(String password) =>
    Isolate.run(() => argon2id(utf8.encode(password), randomBytes(16), security: Argon2Security.owasp2).encoded());

Future<bool> verifyPassword(String password, String encoded) =>
    Isolate.run(() => argon2Verify(encoded, utf8.encode(password)));
