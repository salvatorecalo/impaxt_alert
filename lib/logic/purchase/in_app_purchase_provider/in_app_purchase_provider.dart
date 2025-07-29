import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final inAppPurchaseProvider = Provider((ref) => InAppPurchase.instance);

final productsIds = {
  'rilevazioni_5',
  "rilevazioni_10",
  "rilevazioni_25"
};

final avaibleProductsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final connection = ref.read(inAppPurchaseProvider);
  final response = await connection.queryProductDetails(productsIds);
  if (response.error != null){
    throw Exception('errore nei prodotti');
  }

  return response.productDetails;
});

final purchaseStreamProvider = StreamProvider<List<PurchaseDetails>>((ref) {
  final iap = ref.read(inAppPurchaseProvider);
  return iap.purchaseStream;
});