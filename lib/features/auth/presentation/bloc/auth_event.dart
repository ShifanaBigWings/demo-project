
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SendOtpRequested extends AuthEvent {
  final String email;
  final String? password;
  final String flow;

  const SendOtpRequested({
    required this.email,
    this.password,
    this.flow = 'forgot',
  });

  @override
  List<Object?> get props => [email, password, flow];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  final String flow;
  final String? newPassword;

  const VerifyOtpRequested({
    required this.email,
    required this.otp,
    this.flow = 'register',
    this.newPassword,
  });

  @override
  List<Object?> get props => [
        email,
        otp,
        flow,
        newPassword,
      ];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
