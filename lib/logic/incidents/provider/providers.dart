import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/model/incident/incident.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';


/* --- State --- */
class SensorState {
  final bool incidentDetected;
  final AccelerometerEvent? lastEvent;

  const SensorState({this.incidentDetected = false, this.lastEvent});

  SensorState copyWith({
    bool? incidentDetected,
    AccelerometerEvent? lastEvent,
  }) => SensorState(
    incidentDetected: incidentDetected ?? this.incidentDetected,
    lastEvent: lastEvent ?? this.lastEvent,
  );
}

class SensorStateNotifier extends StateNotifier<SensorState> {
  SensorStateNotifier(this.ref) : super(const SensorState()) {
    /* Ascolta il provider di crash vero e proprio */

    ref.listen<AsyncValue<AccelerometerEvent>>(crashStreamProvider, (_, next) {
      next.whenData((evt) {
        /* 1️⃣ Salva l’evento e alza il flag */
        state = state.copyWith(incidentDetected: true, lastEvent: evt);

        /* 2️⃣ D opo 1 s abbassa il flag (UI chiude dialog) */
        Timer(const Duration(seconds: 1), () {
          state = state.copyWith(incidentDetected: false);
        });
      });
    });
  }

  void resetIncident() {
    state = state.copyWith(incidentDetected: false, lastEvent: null);
  }

  final Ref ref;
}

final sensorDataProvider =
    StateNotifierProvider<SensorStateNotifier, SensorState>(
      (ref) => SensorStateNotifier(ref),
    );

final incidentsProvider = FutureProvider<List<Incident>>((ref) async {
  final dao = ref.watch(daoProvider);
  final rows = await dao.getIncidents();
  return rows.map(Incident.fromMap).toList();
});

final contactsByIncidentProvider =
    FutureProvider.family<List<Map<String, Object?>>, String>((
      ref,
      uuid,
    ) async {
      final dao = ref.watch(daoProvider);
      return dao.getContactsByIncident(uuid);
    });

/* -------------------------------------------------------------------------- */
/* 1.  S T R E A M   D E L   S E N S O R E                                     */
/* -------------------------------------------------------------------------- */

/// Soglia che consideriamo “impulso violento”
const double kCrashThreshold = 30.0;

/// StreamProvider che emette un [AccelerometerEvent] solo
/// quando la forza supera la soglia definita.
final crashStreamProvider = StreamProvider<AccelerometerEvent>((ref) {
  return accelerometerEventStream().where(
    (e) => (e.x.abs() + e.y.abs() + e.z.abs()) > kCrashThreshold,
  );
});

/* -------------------------------------------------------------------------- */
/* 2.  D A T A   A C C E S S   O B J E C T  (SQLite minimal)                   */
/* -------------------------------------------------------------------------- */

class IncidentDao {
  IncidentDao._();

  static final instance = IncidentDao._();

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'impact_alert.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE incidents (
          uuid TEXT PRIMARY KEY,
          created_at TEXT,
          x REAL, y REAL, z REAL,
          synced INTEGER DEFAULT 0,
          called_rescue INTEGER,
          response_time INTEGER,
          lat REAL,
          long REAL
        )
      ''');
        await db.execute('''
        CREATE TABLE incident_contact_notificated (
          incident_uuid TEXT,
          contact_name TEXT,
          contact_phone_number TEXT,
          PRIMARY KEY (incident_uuid, contact_name)
        )
      ''');
        await db.execute('''
        CREATE TABLE contacts (
          contact_name TEXT,
          contact_phone_number TEXT,
          PRIMARY KEY (contact_phone_number, contact_name)
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
        CREATE TABLE incidents (
          uuid TEXT PRIMARY KEY,
          created_at TEXT,
          x REAL, y REAL, z REAL,
          synced INTEGER DEFAULT 0,
          called_rescue INTEGER,
          response_time INTEGER,
          lat REAL,
          long REAL
        )
      ''');
          await db.execute('''
        CREATE TABLE incident_contact_notificated (
          incident_uuid TEXT,
          contact_name TEXT,
          contact_phone_number TEXT,
          PRIMARY KEY (incident_uuid, contact_name)
        )
      ''');
          await db.execute('''
        CREATE TABLE contacts (
          contact_name TEXT,
          contact_phone_number TEXT,
          PRIMARY KEY (contact_phone_number, contact_name)
        )
      ''');
        }
      },
    );
  }

  Future<void> deleteAllIncidents() async {
    final db = await _openDb();
    db.delete("incidents");
    db.delete("incident_contact_notificated");
  }

  Future<void> insert({
    required double x,
    required double y,
    required double z,
    required WidgetRef ref,
    required int called_rescue,
    required int response_time,
    required double lat,
    required double long,
  }) async {
    final db = await _openDb();
    final uuid = const Uuid().v4();

    // Leggi direttamente lo stato attuale della lista contatti
    final contacts = ref.read(contactsProvider);

    await db.insert('incidents', {
      'uuid': uuid,
      'created_at': DateTime.now().toIso8601String(),
      'x': x,
      'y': y,
      'z': z,
      'synced': 0,
      'called_rescue': called_rescue,
      'response_time': response_time,
      'lat': lat,
      'long': long,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    for (var contact in contacts) {
      await db.insert(
        'incident_contact_notificated',
        {
          'incident_uuid': uuid,
          'contact_name': contact.name,
          'contact_phone_number': contact.phoneNumber,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Map<String, Object?>>> getIncidents() async {
    final db = await _openDb();
    return await db.query('incidents', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, Object?>>> getContactsByIncident(
    String incidentUuid,
  ) async {
    final db = await _openDb();
    return await db.query(
      'incident_contact_notificated',
      where: 'incident_uuid = ?',
      whereArgs: [incidentUuid],
    );
  }
}

/// Provider DAO
final daoProvider = Provider<IncidentDao>((_) => IncidentDao.instance);

/* -------------------------------------------------------------------------- */
/* 3.  T T S   P R O V I D E R                                                 */
/* -------------------------------------------------------------------------- */

final ttsProvider = Provider((_) => FlutterTts());

/* -------------------------------------------------------------------------- */
/* 4.  C O N T A T T I   P R O V I D E R                                       */
/* -------------------------------------------------------------------------- */

/// Repository molto semplice che restituisce numeri di telefono.
/// Sostituiscilo con la tua logica di persistenza contatti.
class Contact {
  final String name;
  final String phoneNumber;

  Contact({required this.name, required this.phoneNumber});

  Contact copyWith({String? name, String? phoneNumber}) {
    return Contact(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> addContact(Contact contact, WidgetRef ref) async {
    if (!state.any((c) => c.phoneNumber == contact.phoneNumber)) {
      state = [...state, contact];
    }
    final dao = ref.read(daoProvider);
    final db = await dao._openDb();
    db.insert("contacts", {
      'contact_name': contact.name,
      'contact_phone_number': contact.phoneNumber,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeContact(String phoneNumber) async {
    state = state.where((c) => c.phoneNumber != phoneNumber).toList();
  }

  Future<void> updateContact(Contact updatedContact, WidgetRef ref) async {
    // Sostituisci il contatto nella lista
    state = [
      for (final c in state)
        if (c.phoneNumber == updatedContact.phoneNumber) updatedContact else c,
    ];

    final dao = ref.read(daoProvider);
    final db = await dao._openDb();

    await db.update(
      'contacts_table',
      {
        'contact_name': updatedContact.name,
        'contact_phone_number': updatedContact.phoneNumber,
      },
      where: 'contact_phone_number = ?',
      whereArgs: [updatedContact.phoneNumber],
    );
  }
}

final contactsProvider = StateNotifierProvider<ContactsNotifier, List<Contact>>(
  (ref) {
    return ContactsNotifier();
  },
);

/* -------------------------------------------------------------------------- */
/* 5.  S M S   S E R V I C E   (Twilio Function)                              */
/* -------------------------------------------------------------------------- */
class SmsService {
  static const _functionUrl =
      'https://YOUR_FUNCTION_DOMAIN.twil.io/send-sms'; // <-- sostituisci

  Future<void> sendIncidentAlert(List<Contact> numbers, String message) async {
    final res = await http.post(
      Uri.parse(_functionUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body:
          'numbers=${numbers.join(',')}&message=${Uri.encodeComponent(message)}',
    );

    if (res.statusCode != 200) {
      throw Exception('SMS error: ${res.body}');
    }
  }
}

final smsProvider = Provider<SmsService>((_) => SmsService());

/* -------------------------------------------------------------------------- */
/* 6.  S M S   S E R V I C E   L O C A L E  (Opzionale Android)               */
/*     Se preferisci invio automatico dal device Android con telephony.      */
/* -------------------------------------------------------------------------- */
