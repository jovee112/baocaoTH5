import 'package:http/http.dart' as http;
import 'lib/supabase_config.dart';

Future<void> main() async {
  final bucket = supabaseAvatarBucket;
  final uri = Uri.parse('$supabaseUrl/storage/v1/object/list/$bucket');

  final headers = {
    'Authorization': 'Bearer $supabaseAnonKey',
    'apikey': supabaseAnonKey,
  };

  print('Requesting: $uri');
  try {
    final res = await http.get(uri, headers: headers);
    print('Status: ${res.statusCode}');
    print('Body:');
    print(res.body);
  } catch (e) {
    print('Request failed: $e');
  }
}
