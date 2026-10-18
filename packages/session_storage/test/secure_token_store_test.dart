import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:session_storage/session_storage.dart';

void main() {
  test('a token written before a restart is read by a new store and is gone after logout', () async {
    FlutterSecureStorage.setMockInitialValues({});
    await const SecureTokenStore().write('token-of-ana');

    const afterRestart = SecureTokenStore();
    expect(await afterRestart.read(), 'token-of-ana');

    await afterRestart.clear();
    expect(await const SecureTokenStore().read(), isNull);
  });
}
