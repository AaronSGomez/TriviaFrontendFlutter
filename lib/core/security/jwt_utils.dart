import 'dart:convert';

DateTime? jwtExpiration(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) {
      return null;
    }

    final normalized = base64Url.normalize(parts[1]);
    final payloadJson = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    final exp = payload['exp'];

    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    }
    if (exp is String) {
      final parsed = int.tryParse(exp);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true);
      }
    }
  } catch (_) {
    return null;
  }

  return null;
}

bool isJwtExpired(String token, {Duration clockSkew = const Duration(seconds: 30)}) {
  final expiration = jwtExpiration(token);
  if (expiration == null) {
    // Treat malformed tokens as unusable.
    return true;
  }

  return DateTime.now().toUtc().isAfter(expiration.subtract(clockSkew));
}
