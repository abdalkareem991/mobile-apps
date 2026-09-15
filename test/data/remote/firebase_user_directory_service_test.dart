import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/data/remote/firebase/firebase_user_directory_service.dart';

void main() {
  test('hashPhone is stable and does not expose the raw number', () {
    final first = FirebaseUserDirectoryService.hashPhone('+966 50 123 4567');
    final second = FirebaseUserDirectoryService.hashPhone('+966501234567');

    expect(first, second);
    expect(first, hasLength(64));
    expect(first, isNot(contains('966501234567')));
  });
}
