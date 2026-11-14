import 'dart:convert';
import 'package:http/http.dart' as http;

class RpcService {
  String baseUrl;
  String authToken;

  RpcService(this.baseUrl, this.authToken);

  Future<dynamic> call(String obj, String method, [Map<String, dynamic>? params]) async {
    final url = Uri.parse('$baseUrl/cgi-bin/luci/rpc/$obj?auth=$authToken');
    final body = jsonEncode({
      'method': method,
      'params': params ?? [],
    });

    final response = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
    
    if (response.statusCode != 200) {
      throw Exception('فشل الاتصال بالراوتر (كود ${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    if (data['error'] != null) {
      throw Exception('خطأ من الراوتر: ${data['error']}');
    }
    return data['result'];
  }
}
