import 'package:autocare_async_kit/async_kit.dart';
import 'package:autocare_supabase_adapter/errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'function authorization failures retain their status and server message',
    () {
      final error = supabaseAppError(
        const FunctionException(
          status: 401,
          details: {'error': 'Session revoked'},
        ),
      );
      expect(error.type, AppErrorType.auth);
      expect(error.message, 'Session revoked');
      expect(error.retryable, isFalse);
    },
  );
  test('function service failures remain retryable and keep an error code', () {
    final error = supabaseAppError(const FunctionException(status: 503));
    expect(error.type, AppErrorType.server);
    expect(error.code, 'SRV_503');
    expect(error.retryable, isTrue);
  });
  test(
    'auth failures retain business messages and missing-status network mapping',
    () {
      expect(
        supabaseAppError(
          const AuthException('Wrong password', statusCode: '400'),
        ).message,
        'Wrong password',
      );
      expect(
        supabaseAppError(const AuthException('No connection')).type,
        AppErrorType.network,
      );
    },
  );
  test('existing application errors are not replaced', () {
    const error = AppError('Already normalized');
    expect(supabaseAppError(error), same(error));
  });
  test(
    'async adapter returns results and normalizes failures before UI callbacks',
    () async {
      expect(await withSupabaseErrors(() async => 42), 42);
      await expectLater(
        withSupabaseErrors(() async {
          throw const AuthException('Expired', statusCode: '401');
        }),
        throwsA(
          isA<AppError>().having(
            (error) => error.type,
            'type',
            AppErrorType.auth,
          ),
        ),
      );
    },
  );
}
