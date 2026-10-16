
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) {
    return remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    await remoteDataSource.register(
      email: email,
      password: password,
    );
    return true;
  }

  @override
  Future<void> sendOtp({
    required String email,
    String flow = 'forgot',
  }) {
    return remoteDataSource.sendOtp(
      email: email,
      flow: flow,
    );
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    String flow = 'register',
    String? newPassword,
  }) {
    return remoteDataSource.verifyOtp(
      email: email,
      otp: otp,
      flow: flow,
      newPassword: newPassword,
    );
  }
}
