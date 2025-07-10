import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsService {
  static const _username = const String.fromEnvironment("CLICK_SEND_USERNAME");
  static const _apiKey   = const String.fromEnvironment("CLICK_SEND_API");
  static final _authHeader = 'Basic ${base64Encode(utf8.encode('$_username:$_apiKey'))}';

  static const _url = 'https://rest.clicksend.com/v3/sms/send';

  Future<void> sendIncidentAlert(
      List<String> contacts, String message) async {

    final res = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': _authHeader,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'messages': contacts
            .map((n) => {
          'source': 'flutter',
          'to': n,
          'body': message,
        })
            .toList()
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('ClickSend error: ${res.body}');
    }
  }
}
