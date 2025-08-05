
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/contacts/contacts_provider.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class IncidentDao {
  IncidentDao._();

  static final instance = IncidentDao._();

  Future<Database> openMyDb() async {
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
    final db = await openMyDb();
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
    final db = await openMyDb();
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

      final session = ref.read(authSessionProvider).value;
      if (session != null) {
        final userId = session.user.id;
        await supabase.from("incident_contact_notificated")
            .insert({
          "user_id": userId,
          'incident_uuid': uuid,
          'contact_name': contact.name,
          'contact_phone_number': contact.phoneNumber,
        });
      }
    }
  }

  Future<List<Map<String, Object?>>> getIncidents() async {
    final db = await openMyDb();
    return await db.query('incidents', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, Object?>>> getContactsByIncident(
      String incidentUuid,
      ) async {
    final db = await openMyDb();
    return await db.query(
      'incident_contact_notificated',
      where: 'incident_uuid = ?',
      whereArgs: [incidentUuid],
    );
  }
}
