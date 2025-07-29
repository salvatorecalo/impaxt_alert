import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/crash_alert_page/crash_alert_page.dart';
import 'package:impaxt_alert/logic/incidents/incident_list_item./incident_list_item.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/logic/user_logic/auth_controller/provider/auth_controller_provider.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:impaxt_alert/pages/home_page/pages/index.dart';
import 'package:impaxt_alert/pages/login_page/login_page.dart';
import 'package:impaxt_alert/pages/home_page/pages/history_page/widgets/index.dart';
import 'package:impaxt_alert/pages/utils/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage(
      {
        super.key,
        required this.onGoToShop,
      });

  final VoidCallback? onGoToShop;
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool _isDialogOpen = false;
  bool _hasSyncedOnce = false;
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDataOnce();
    });
  }

  Future<void> _syncDataOnce() async {
    if (!_hasSyncedOnce) {
      _hasSyncedOnce = true;
      final authController = ref.read(authControllerProvider);
      try {
        await authController.pushLocalIncidents(ref);
        await authController.pushLocalContacts(ref);
      } catch (e) {
        print('Errore durante la sincronizzazione: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    // 1. Microfono
    final micGranted = await _ensurePermission(
      Permission.microphone,
      readableName: 'Microfono',
      onPermanentDenied: _showMicSettingsDialog,
      onDenied: _showMicPermissionDialog,
    );

    if (!micGranted) return;  // senza microfono esco

    // 2. Location foreground
    final locGranted = await _ensurePermission(
      Permission.locationWhenInUse,    // o Permission.location
      readableName: 'Posizione (in uso)',
      onPermanentDenied: _showLocSettingsDialog,
      onDenied: _showLocPermissionDialog,
    );

    if (!locGranted) return;

    // 3. Location background (facoltativo, solo Android ≥ 10)
    if (await Permission.locationAlways.isDenied ||
        await Permission.locationAlways.isRestricted) {
      await _ensurePermission(
        Permission.locationAlways,
        readableName: 'Posizione in background',
        onPermanentDenied: _showLocSettingsDialog,
        onDenied: _showLocPermissionDialog,
      );
    }
  }

  /// Helper generico (puoi metterlo in un PermissionService come nell’esempio precedente)
  Future<bool> _ensurePermission(
      Permission permission, {
        required String readableName,
        required VoidCallback onDenied,
        required VoidCallback onPermanentDenied,
      }) async {
    var status = await permission.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      onPermanentDenied();
      return false;
    }

    // Chiedo il permesso
    status = await permission.request();

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      onPermanentDenied();
    } else {
      onDenied();
    }
    return false;
  }


  void _showLocPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permesso Localizzazione'),
        content: const Text(
            'Questa app ha bisogno del permesso alla posizione (sempre) per funzionare correttamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissions();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  void _showMicPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permesso Microfono'),
        content: Text('Questa app ha bisogno del permesso del microfono per funzionare correttamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMicSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permesso Microfono Localizzazione'),
        content: Text('Il permesso per il microfomo è stato negato. Per abilitarlo, vai nelle impostazioni dell\'app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Richiedi'),
          ),
        ],
      ),
    );
  }


  void _showLocSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permesso Localizzazione'),
        content: Text('Il permesso per accedere alla posizione è stato negato. Per abilitarlo, vai nelle impostazioni dell\'app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncAfterNewIncident() async {
    final authController = ref.read(authControllerProvider);
    try {
      await authController.pushLocalIncidents(ref);
      await authController.pushLocalContacts(ref);
      ref.invalidate(incidentsProvider);
    } catch (e) {
      print('Errore sincronizzazione post-incident: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final incidentsAsync = ref.watch(incidentsProvider);
    ref.invalidate(incidentsProvider);
    final session = ref.watch(authSessionProvider);
   //print("session $session");
    ref.listen(sensorDataProvider, (previous, state) async {
      if (state.incidentDetected && state.lastEvent != null && !_isDialogOpen) {
        final incidents = ref.read(incidentsProvider).value ?? [];
        final now = DateTime.now();
        final todayCount = incidents.where((incident) {
          final incidentDate = DateTime.parse(incident.createdAt.toString());
          return incidentDate.year == now.year &&
              incidentDate.month == now.month &&
              incidentDate.day == now.day;
        }).length;

        if (todayCount >= 3) {
          if (!_isDialogOpen) {
            _isDialogOpen = true;
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("Limite giornaliero raggiunto"),
                content: Text("Hai esaurito il numero di rilevazioni possibili giornaliere. Riprova domani o acquista la possibilità di fare rilevazioni."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                      MaterialPageRoute(builder: (context) => ShopPage(),
                      ),
                    ),
                    child: TextButton(
                        child: Text("Acquista"),
                      onPressed: () {
                          Navigator.pop(context);
                          widget.onGoToShop?.call();
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annulla"),
                  ),
                ],
              ),
            ).then((_) => _isDialogOpen = false);
          }
          return;
        }

        _isDialogOpen = true;

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CrashAlertPage(evt: state.lastEvent!)),
        );

        _isDialogOpen = false;
        await _syncAfterNewIncident();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'ImpactAlert',
            style: TextStyle(
                fontWeight: FontWeight.bold
            )
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          session.when(
              data: (session) {
                return session == null ? _GuestBanner() : SizedBox.shrink();
              },
              error: (error, stack) => Text(error.toString()),
              loading: () => CircularProgressIndicator()),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Storico degli avvenimenti',
                style: TextStyle(fontSize: 18, letterSpacing: 1)),
          ),
          Expanded(
            child: incidentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Errore: $e')),
              data: (list) => list.isEmpty
                  ? const NoIncident()
                  : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => IncidentListItem(incident: list[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextButton(
              onPressed: () async {
                await launchUrl(
                  Uri.parse(
                    "https://salvatorecalo.github.io/impaxt_alert_privacy_policy.github.io/",
                  ),
                );
              },
              child: Text(
                "Privacy e trattamento dati",
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPageAlternative extends ConsumerStatefulWidget {
  const HistoryPageAlternative({super.key});

  @override
  ConsumerState<HistoryPageAlternative> createState() => _HistoryPageAlternativeState();
}

class _HistoryPageAlternativeState extends ConsumerState<HistoryPageAlternative> {
  late Future<PermissionStatus> _microphonePermission;

  @override
  void initState() {
    super.initState();
    _microphonePermission = _checkAndRequestPermission();
  }

  Future<PermissionStatus> _checkAndRequestPermission() async {
    final status = await Permission.microphone.status;

    if (status.isDenied) {
      return await Permission.microphone.request();
    }

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: _microphonePermission,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Center(child: CircularProgressIndicator())),
          );
        }

        // Resto del codice della tua pagina...
        return Scaffold(
          appBar: AppBar(
            title: const Text('ImpactAlert'),
          ),
          body: const Center(
            child: Text('Permesso microfono gestito correttamente'),
          ),
        );
      },
    );
  }
}

/* ---------- Widget banner ospite ---------- */
class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(8)),
    child: Column(
      children: [
        Text('Accedi per sincronizzare la cronologia su più dispositivi',
            style: TextStyle(color: white)),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: white,
            foregroundColor: blue,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: const Text('Accedi'),
        ),
      ],
    ),
  );
}