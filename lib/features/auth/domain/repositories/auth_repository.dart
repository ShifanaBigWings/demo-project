
abstract class AuthRepository {
  Future<bool> login({
    required String email,
    required String password,
  });

  Future<bool> register({
    required String email,
    required String password,
  });

  Future<void> sendOtp({
    required String email,
    String flow = 'forgot',
  });

  Future<bool> verifyOtp({
    required String email,
    required String otp,
    String flow = 'register',
    String? newPassword,
  });
}
