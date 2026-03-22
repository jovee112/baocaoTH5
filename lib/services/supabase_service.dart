import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import '../supabase_config.dart';

class SupabaseService {
  /// Upload raw bytes to Supabase storage using REST API.
  /// Returns public URL on success, null on failure.
  Future<String?> uploadAvatar(Uint8List bytes, String filename) async {
    const bucket = supabaseAvatarBucket;
    final uploadPath = 'public/$filename';

    final uri = Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$uploadPath');

    final mimeType = lookupMimeType(filename) ?? 'application/octet-stream';

    final headers = {
      'Authorization': 'Bearer $supabaseAnonKey',
      'Content-Type': mimeType,
      // Supabase requires the apikey header for browser CORS in some setups
      'apikey': supabaseAnonKey,
    };

    final res = await http.put(uri, headers: headers, body: bytes);
    // Log response for debugging (CORS, auth, etc.)
    if (res.statusCode == 200 || res.statusCode == 201) {
      return '$supabaseUrl/storage/v1/object/public/$bucket/$uploadPath';
    } else {
      // Print status and body to help debugging upload failures
      // Use debugPrint to avoid flooding release logs.
      try {
        // ignore: avoid_print
        debugPrint('Supabase upload failed: ${res.statusCode}');
        // ignore: avoid_print
        debugPrint('Response body: ${res.body}');
      } catch (_) {}
      return null;
    }
  }
}
