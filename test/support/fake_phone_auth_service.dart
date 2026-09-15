import 'package:myapp/data/repositories/phone_auth_service.dart';

class FakePhoneAuthService implements PhoneAuthService {
  @override
  Future<String> sendCode(String phoneNumber) async => 'test-verification-id';

  @override
  Future<void> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {}

  @override
  Future<void> signOut() async {}
}
