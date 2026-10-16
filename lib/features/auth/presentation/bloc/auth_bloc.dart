
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await loginUseCase(
        email: event.email,
        password: event.password,
      );

      if (success) {
        emit(const AuthSuccess());
      } else {
        emit(const AuthFailure('Invalid email or password.'));
      }
    } catch (e) {
      emit(AuthFailure('Login failed. Please try again. Details: $e'));
    }
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      if (event.flow == 'register') {
        final password = event.password;

        if (password == null || password.isEmpty) {
          emit(
            const AuthFailure(
              'Password is required for registration.',
            ),
          );
          return;
        }

        await registerUseCase(
          email: event.email,
          password: password,
        );

        final loggedIn = await loginUseCase(
          email: event.email,
          password: password,
        );

        if (!loggedIn) {
          emit(
            const AuthFailure(
              'Account created, but sign-in failed. '
              'Please sign in and try verification again.',
            ),
          );
          return;
        }
      }

      await sendOtpUseCase(
        email: event.email,
        flow: event.flow,
      );

      emit(OtpSent(event.email));
    } catch (e) {
      emit(AuthFailure('Could not send OTP. Details: $e'));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final verified = await verifyOtpUseCase(
        email: event.email,
        otp: event.otp,
        flow: event.flow,
        newPassword: event.newPassword,
      );

      if (verified) {
        emit(const OtpVerified());
      } else {
        emit(
          const AuthFailure(
            'Invalid OTP or recovery details. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(AuthFailure('OTP verification failed. Details: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final success = await registerUseCase(
        email: event.email,
        password: event.password,
      );

      if (success) {
        emit(const RegistrationSuccess());
      } else {
        emit(const AuthFailure('Registration failed.'));
      }
    } catch (e) {
      emit(AuthFailure('Registration failed. Details: $e'));
    }
  }
}
