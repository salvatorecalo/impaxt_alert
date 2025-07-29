import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/purchase/in_app_purchase_provider/in_app_purchase_provider.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:impaxt_alert/pages/home_page/pages/shop_page/widgets/index.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(avaibleProductsProvider);
    final sessioAsync = ref.watch(authSessionProvider);
    return SafeArea(
      child: Scaffold(
        body: sessioAsync.when(
            data: (session) {
              if (session == null) {
                return NoLogged();
              } else {
                return productsAsync.when(
                  data: (products) =>
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ShopItem(
                                    nRilevazioni: int.parse(product.id
                                        .split('_')
                                        .last),
                                    price: double.parse(product.price.replaceAll(
                                        RegExp(r'[^\d.]'), '')),
                                  );
                                },
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
                                    "Privacy e trattamento dati per acquisti",
                                    style: TextStyle(fontSize: 16, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Errore: $e')),
                );
              }
            },
            error: (error, trace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator(),
        )
      ),
    );
  }

}
