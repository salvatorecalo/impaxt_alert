import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/contacts/contacts_notifier/contacts_notifier.dart';
import 'package:impaxt_alert/logic/incidents/provider/contacts/model/my_contact_model.dart';

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
      (ref) {
    return ContactsNotifier();
  },
);
