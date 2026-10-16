
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../../../appwrite_service.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login({
    required String email,
    required String password,
  });

  Future<void> register({
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

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Map<String, String> _verificationUserIds = {};
  final Map<String, String> _recoveryUserIds = {};

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    try {
      await AppwriteService.account.createEmailPasswordSession(
        email: normalizedEmail,
        password: password,
      );

      debugPrint('APPWRITE LOGIN: Success');
      return true;
    } on AppwriteException catch (e) {
      debugPrint(
        'APPWRITE LOGIN ERROR: '
        'code=${e.code}, type=${e.type}, message=${e.message}',
      );

      if (e.type == 'user_session_already_exists') {
        try {
          await AppwriteService.account.deleteSession(
            sessionId: 'current',
          );

          await AppwriteService.account.createEmailPasswordSession(
            email: normalizedEmail,
            password: password,
          );

          debugPrint('APPWRITE LOGIN: Success after clearing old session');
          return true;
        } on AppwriteException catch (retryError) {
          debugPrint(
            'APPWRITE LOGIN RETRY ERROR: '
            'code=${retryError.code}, '
            'type=${retryError.type}, '
            'message=${retryError.message}',
          );

          if (retryError.code == 400 || retryError.code == 401) {
            return false;
          }

          rethrow;
        }
      }

      if (e.code == 400 || e.code == 401) {
        return false;
      }

      rethrow;
    } catch (e) {
      debugPrint('UNEXPECTED LOGIN ERROR: $e');
      rethrow;
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await AppwriteService.account.create(
        userId: ID.unique(),
        email: email.trim(),
        password: password,
      );

      debugPrint('APPWRITE REGISTRATION: Account created');
    } on AppwriteException catch (e) {
      debugPrint(
        'APPWRITE REGISTRATION ERROR: '
        'code=${e.code}, type=${e.type}, message=${e.message}',
      );

      if (e.code == 409) {
        throw Exception(
          'This email is already registered. Please sign in instead.',
        );
      }

      rethrow;
    }
  }

  @override
  Future<void> sendOtp({
    required String email,
    String flow = 'forgot',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      if (flow == 'register') {
        final currentUser = await AppwriteService.account.get();

        if (currentUser.email.trim().toLowerCase() != normalizedEmail) {
          throw Exception(
            'Please sign in with the account you want to verify.',
          );
        }

        final token =
            await AppwriteService.account.createEmailVerificationOTP();

        _verificationUserIds[normalizedEmail] = token.userId;
        debugPrint('APPWRITE OTP: Verification OTP sent');
      } else {
        // Recovery OTP does not require an existing signed-in session.
        final token = await AppwriteService.account.createRecoveryOTP(
  email: normalizedEmail,
);

        _recoveryUserIds[normalizedEmail] = token.userId;
        debugPrint('APPWRITE OTP: Recovery OTP requested');
      }
    } on AppwriteException catch (e) {
      debugPrint(
        'APPWRITE OTP ERROR: '
        'code=${e.code}, type=${e.type}, message=${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<bool> verifyOtp({
    required String email,
    required String otp,
    String flow = 'register',
    String? newPassword,
  }) async {
    final key = email.trim().toLowerCase();

    try {
      if (flow == 'forgot') {
        if (newPassword == null || newPassword.length < 8) {
          throw Exception(
            'Enter a new password containing at least 8 characters.',
          );
        }

        final userId = _recoveryUserIds[key];

        if (userId == null) {
          throw Exception(
            'Please request a new password recovery OTP.',
          );
        }

        await AppwriteService.account.updateRecoveryOTP(
          userId: userId,
          secret: otp.trim(),
          password: newPassword,
        );

        _recoveryUserIds.remove(key);
        debugPrint('APPWRITE PASSWORD RECOVERY: Password updated');
        return true;
      }

      final userId = _verificationUserIds[key];

      if (userId == null) {
        throw Exception('Please request a new verification code.');
      }

      await AppwriteService.account.updateEmailVerificationOTP(
        userId: userId,
        secret: otp.trim(),
      );

      _verificationUserIds.remove(key);
      debugPrint('APPWRITE OTP: Email verified successfully');
      return true;
    } on AppwriteException catch (e) {
      debugPrint(
        'APPWRITE OTP VERIFICATION ERROR: '
        'code=${e.code}, type=${e.type}, message=${e.message}',
      );

      if (e.code == 400 || e.code == 401) {
        return false;
      }

      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    throw UnimplementedError(
      'Use the recovery OTP to reset the password.',
    );
  }

}
