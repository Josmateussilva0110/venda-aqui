import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:flutter/material.dart';
import 'package:vendaqui/core/stock/stock_level.dart';
import 'package:vendaqui/core/theme/theme_controller.dart';
import 'package:vendaqui/features/auth/domain/auth_repository.dart';
import 'package:vendaqui/features/auth/domain/merchant.dart';
import 'package:vendaqui/features/dashboard/domain/stock_overview.dart';
import 'package:vendaqui/features/products/domain/photo_picker.dart';
import 'package:vendaqui/features/products/domain/product.dart';
import 'package:vendaqui/features/products/domain/products_repository.dart';

const testMerchant = Merchant(id: 'm1', name: 'Mercearia da Rita', phone: '+5586999990000');

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({required this.signedIn});

  final bool signedIn;

  @override
  Future<Merchant?> restoreSession() async => signedIn ? testMerchant : null;

  @override
  Future<bool> isPhoneAvailable(String phoneDigits) async => true;

  @override
  Future<Merchant> register({required String name, required String phoneDigits, required String pin}) async => testMerchant;

  @override
  Future<Merchant> login({required String phoneDigits, required String pin}) async => testMerchant;

  @override
  Future<void> requestPinRecovery(String phoneDigits) async {}

  @override
  Future<Merchant> confirmPinRecovery({required String phoneDigits, required String code, required String pin}) async => testMerchant;

  @override
  Future<void> logout() async {}
}

/// Nomes longos de propósito, para pegar texto estourando o layout.
final testProducts = [
  const Product(
    id: 'p1',
    name: 'Tomate italiano selecionado da roça do Seu Raimundo',
    photoUrl: null,
    salePriceCents: 800,
    costPriceCents: 450,
    quantity: 12.5,
    soldByWeight: true,
    stockLevel: StockLevel.ok,
  ),
  const Product(
    id: 'p2',
    name: 'Alface crespa',
    photoUrl: null,
    salePriceCents: 300,
    costPriceCents: 120,
    quantity: 4,
    soldByWeight: false,
    stockLevel: StockLevel.low,
  ),
  const Product(
    id: 'p3',
    name: 'Cebola roxa',
    photoUrl: null,
    salePriceCents: 123456,
    costPriceCents: 99999,
    quantity: 0,
    soldByWeight: true,
    stockLevel: StockLevel.out,
  ),
];

class FakeProductsRepository implements ProductsRepository {
  @override
  Future<ProductPage> list({
    required String search,
    required StockFilter filter,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    return ProductPage(
      items: offset == 0 ? testProducts : const [],
      total: testProducts.length,
      stockCounts: const StockCounts(all: 3, low: 1, out: 1),
      lowStockThreshold: 5,
    );
  }

  @override
  Future<Product> get(String id) async => testProducts.firstWhere((product) => product.id == id);

  @override
  Future<String> create(ProductInput input) async => 'new';

  @override
  Future<void> update(String id, ProductInput input) async {}

  @override
  Future<void> restock(String id, double quantity) async {}

  @override
  Future<void> uploadPhoto(String id, ProductPhoto photo) async {}
}

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<StockOverview> stockOverview({required int alertLimit}) async {
    return StockOverview(
      totalProducts: 3,
      lowCount: 1,
      outCount: 1,
      alerts: [
        for (final product in testProducts.where((product) => product.stockLevel != StockLevel.ok))
          StockAlert(
            productId: product.id,
            name: product.name,
            photoUrl: null,
            quantity: product.quantity,
            soldByWeight: product.soldByWeight,
            level: product.stockLevel,
          ),
      ],
    );
  }
}

class FakePhotoPicker implements PhotoPicker {
  @override
  Future<PhotoPickResult> pick(PhotoOrigin origin) async => const PhotoCancelled();
}

class _MemoryThemeStore implements ThemePreferenceStore {
  ThemeMode? saved;

  @override
  Future<ThemeMode?> read() async => saved;

  @override
  Future<void> write(ThemeMode mode) async => saved = mode;
}

/// Tema fixo em claro nos testes, sem tocar no armazenamento do aparelho.
ThemeController lightThemeController() => ThemeController(_MemoryThemeStore(), initial: ThemeMode.light);
