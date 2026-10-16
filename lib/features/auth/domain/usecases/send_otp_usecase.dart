
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> call({
    required String email,
    String flow = 'forgot',
  }) {
    return repository.sendOtp(
      email: email,
      flow: flow,
    );
  }
}
