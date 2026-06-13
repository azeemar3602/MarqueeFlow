import 'dart:io';

import 'package:http/http.dart' as http;

import '../services/api_service.dart';

ApiException mapRequestError(Object error) {
  if (error is ApiException) return mapApiException(error);

  if (error is SocketException) {
    return ApiException(
      'Unable to connect. Check your internet connection and try again.',
      code: 'NETWORK',
    );
  }

  if (error is http.ClientException) {
    final message = error.message.toLowerCase();
    if (message.contains('failed host lookup') || message.contains('network is unreachable')) {
      return ApiException(
        'Unable to reach MarqueeFlow servers. Check your internet connection and try again.',
        code: 'NETWORK',
      );
    }
    if (message.contains('connection timed out')) {
      return ApiException(
        'The connection timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }
    return ApiException(
      'Network error. Please check your connection and try again.',
      code: 'NETWORK',
    );
  }

  if (error is FormatException) {
    return ApiException(
      'Unexpected server response. Please try again later.',
      code: 'PARSE',
    );
  }

  return ApiException(
    'Something went wrong. Please try again.',
    code: 'UNKNOWN',
  );
}

ApiException mapApiException(ApiException error) {
  switch (error.code) {
    case 'UNAUTHORIZED':
      return ApiException('Your session expired. Please sign in again.', code: error.code);
    case 'FORBIDDEN':
      return ApiException(
        error.message.contains('Super Admin')
            ? error.message
            : 'You do not have permission to perform this action.',
        code: error.code,
      );
    case 'BUSINESS_PENDING':
      return ApiException(
        'Your business is pending Super Admin approval. You can only view the approval status until approved.',
        code: error.code,
      );
    case 'BUSINESS_REJECTED':
      return ApiException(
        'Your business registration was rejected. Contact MarqueeFlow support.',
        code: error.code,
      );
    case 'BUSINESS_SUSPENDED':
      return ApiException(
        'Your business account is suspended. Contact MarqueeFlow support.',
        code: error.code,
      );
    case 'BUSINESS_NOT_APPROVED':
      return ApiException(
        'Your business is not approved yet. Complete approval before using bookings.',
        code: error.code,
      );
    case 'SLOT_FULL':
      return ApiException('That slot is fully booked. Choose another slot.', code: error.code);
    case 'VALIDATION':
      return ApiException(error.message, code: error.code);
    default:
      return error;
  }
}
