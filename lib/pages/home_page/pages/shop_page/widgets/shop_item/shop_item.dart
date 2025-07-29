import 'package:flutter/material.dart';
import 'package:impaxt_alert/logic/purchase/in_app_purchase_provider/in_app_purchase_provider.dart';
import 'package:impaxt_alert/pages/utils/index.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopItem extends ConsumerWidget {
  final int nRilevazioni;
  final double price;

  const ShopItem({super.key, required this.nRilevazioni, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(avaibleProductsProvider);

    return productsAsync.when(
      data: (products) {
        final product = products.firstWhere(
              (p) => p.id == 'rilevazioni_$nRilevazioni',
          orElse: () => throw Exception('Prodotto non trovato'),
        );

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: blue,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              Text(
                '$nRilevazioni rilevazioni',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  fontSize: 20
                ),
              ),
              Text(
                  product.price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    50
                  ),
                  backgroundColor: blue,
                ),
                onPressed: () async {
                  final purchaseParam = PurchaseParam(productDetails: product);
                  final connection = ref.read(inAppPurchaseProvider);
                  await connection.buyConsumable(
                    purchaseParam: purchaseParam,
                    autoConsume: true,
                  );
                },
                child: const Text(
                    'Acquista',
                  style: TextStyle(
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Errore: $e'),
    );
  }
}
