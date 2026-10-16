import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<bool> call({
    required String email,
    required String password,
  }) {
    return repository.register(
      email: email,
      password: password,
    );
  }
}
