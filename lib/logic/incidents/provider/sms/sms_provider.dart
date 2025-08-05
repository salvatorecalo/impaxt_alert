import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/sms/model/sms_model.dart';

final smsProvider = Provider((ref) {
  return SmsService();
});