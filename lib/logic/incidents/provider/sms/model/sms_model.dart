import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:impaxt_alert/logic/incidents/provider/contacts/model/my_contact_model.dart';

class SmsService {
  static const _url = const String.fromEnvironment("SERVER_URL");

  Future<void> sendIncidentAlert(List<Contact> contacts, String message) async {
    final futures = contacts.map((contact) async {
      final cleanedNumber = contact.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final formattedNumber = 'whatsapp:$cleanedNumber';

      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'to': formattedNumber,
          'message': message,
        }),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Errore invio messaggio a ${contact.phoneNumber}: ${res.body}');
      }
    });

    await Future.wait(futures);
  }
}
