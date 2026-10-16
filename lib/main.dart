import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/send_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/create_account_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/verify_otp_page.dart';

void main() {
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
  );

  runApp(
    RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: BlocProvider<AuthBloc>(
        create: (context) {
          final repository = context.read<AuthRepository>();

          return AuthBloc(
            loginUseCase: LoginUseCase(repository),
            registerUseCase: RegisterUseCase(repository),
            sendOtpUseCase: SendOtpUseCase(repository),
            verifyOtpUseCase: VerifyOtpUseCase(repository),
          );
        },
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Project',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/register': (context) => const CreateAccountPage(),
        '/verify-otp': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, String>;

          return VerifyOtpPage(
            email: args['email']!,
            flow: args['flow']!,
            password: args['password'],
          );
        },
      },
    );
  }
}
