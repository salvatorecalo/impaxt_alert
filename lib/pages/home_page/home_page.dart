import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/max_incidents_for_plan/max_incidents_for_plan.dart';
import 'package:impaxt_alert/logic/purchase/in_app_purchase_provider/in_app_purchase_provider.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:impaxt_alert/pages/home_page/pages/index.dart';
import 'package:impaxt_alert/pages/utils/index.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController controller;
  int _currentPageIndex = 0;
  bool _didMaxCheckIncidents = false;
  Timer? _incidentResetTimer;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndInsertMaxIncidents();
      _resetNumberIncidentsAfterDay();

      _incidentResetTimer = Timer.periodic(
        const Duration(minutes: 1),
          (_) => _resetNumberIncidentsAfterDay(),
      );
    });
  }

  Future<void> _resetNumberIncidentsAfterDay() async {
    final now = DateTime.now();
    final maxIncidents = ref.read(maxIncidentsprovider);
    final session = await ref.read(authSessionProvider.future);

    if (session != null) {
      final userId = session.user.id;
      final lastUpdate = await maxIncidents.getLastUserIncidentsUpdate(userId);

      if (lastUpdate == null) return;

      final difference = now.difference(lastUpdate);
      if (difference.inHours >= 24) {
        await maxIncidents.editUserMaxIncidentsNumber(3, userId);
        await maxIncidents.updateLastUserUpdate(userId);
        print("Incidenti resettati per $userId");
      }
    }
  }


  Future<void> _checkAndInsertMaxIncidents() async {
    if (_didMaxCheckIncidents) return;
    _didMaxCheckIncidents = true;

    final asyncSession = ref.read(authSessionProvider); // AsyncValue<Session?>

    await asyncSession.when(
      data: (sessionData) async {
        // user is not logged
        if (sessionData == null) return;

        final userId = sessionData.user.id;
        final maxIncidentsNotifier = ref.read(maxIncidentsprovider);
        final exists = await maxIncidentsNotifier.checkIfUserExists(userId);
        if (!exists) {
          await maxIncidentsNotifier.insertUserInMaxIncidentTable(userId);
          print("Inserito record max incident per user $userId");
        }
      },
      loading: () {
        print("Session loading...");
      },
      error: (error, stack) {
        print("Errore nel recuperare la sessione: $error");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _incidentResetTimer?.cancel();
    controller.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void onBottomNavTap(int index) {
    controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(purchaseStreamProvider, (prev, next) {
      next.whenData((purchases) {
        for (var purchase in purchases) {
          if (purchase.status == PurchaseStatus.purchased) {

            InAppPurchase.instance.completePurchase(purchase);
            final session = ref.watch(authSessionProvider);
            // 🎉 Aggiungi rilevazioni al profilo utente
            // Puoi usare un provider o chiamare Supabase qui.
            final int n_rilevazioni;
            switch (purchase.productID) {
              case 'rilevazioni_5':
                n_rilevazioni =  5;
              case 'rilevazioni_10':
                n_rilevazioni = 10;
              case 'rilevazioni_25':
                n_rilevazioni = 25;
              default:
                return 0;
            }

            final maxIncidentsProvider = ref.watch(maxIncidentsprovider);
            maxIncidentsProvider.editUserMaxIncidentsNumber(
              n_rilevazioni,
              session.value!.user.id,
            );
          }
        }
      });
    });

    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: [
          HistoryPage(onGoToShop: (){
            setState(() {
              _currentPageIndex = 2;
            });
          },),
          ShopPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: blue,
        currentIndex: _currentPageIndex,
        onTap: onBottomNavTap,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
    );
  }
}
