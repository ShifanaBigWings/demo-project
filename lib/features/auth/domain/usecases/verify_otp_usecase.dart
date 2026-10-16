
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<bool> call({
    required String email,
    required String otp,
    String flow = 'register',
    String? newPassword,
  }) {
    return repository.verifyOtp(
      email: email,
      otp: otp,
      flow: flow,
      newPassword: newPassword,
    );
  }
}
