import 'package:autocare_async_kit/async_kit.dart' show AppError;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, FunctionException;

/// Convert SDK errors at the API boundary, before they reach shared UI.
AppError supabaseAppError(Object error) {
  if (error is FunctionException) {
    final details = error.details;
    return AppError.fromStatus(
      error.status,
      details is Map ? details['error']?.toString() : null,
    );
  }
  if (error is AuthException) {
    final status = int.tryParse(error.statusCode ?? '');
    return status == null
        ? const AppError.network()
        : AppError.fromStatus(status, error.message);
  }
  return AppError.from(error);
}

Future<T> withSupabaseErrors<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (error) {
    throw supabaseAppError(error);
  }
}
