import 'package:vendaqui/core/network/cancel_signal.dart';
import 'package:flutter/material.dart';
import 'package:vendaqui/core/stock/stock_level.dart';
import 'package:vendaqui/core/theme/theme_controller.dart';
import 'package:vendaqui/core/network/app_failure.dart';
import 'package:vendaqui/core/stock/stock_changes.dart';
import 'package:vendaqui/features/customers/domain/customer.dart';
import 'package:vendaqui/features/customers/domain/customers_repository.dart';
import 'package:vendaqui/features/reports/domain/sales_report.dart';
import 'package:vendaqui/features/sales/domain/sale.dart';
import 'package:vendaqui/features/sales/domain/sales_repository.dart';
import 'package:vendaqui/features/sales/presentation/controllers/sale_cart_controller.dart';
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
  Future<TodaySales> todaySales(DateTime now, {required int recentLimit}) async => TodaySales(
    count: 2,
    totalCents: 4590,
    recent: [
      RecentSale(
        id: 's1',
        productNames: const ['Banana prata', 'Cheiro-verde'],
        createdAt: DateTime(2026, 11, 4, 8, 1),
        paymentMethod: 'credit',
        totalCents: 1200,
        customerName: 'Maria das Graças Oliveira Santos',
      ),
      RecentSale(
        id: 's2',
        productNames: const ['Macaxeira'],
        createdAt: DateTime(2026, 11, 4, 6, 45),
        paymentMethod: 'pix',
        totalCents: 3390,
      ),
    ],
  );

  @override
  Future<CreditOverview> creditOverview() async => const CreditOverview(owingCount: 0, owedCents: 0);

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

/// Catálogo da venda montado a partir de [testProducts]; vendas guardadas em memória.
class FakeSalesRepository implements SalesRepository {
  FakeSalesRepository({List<CatalogProduct>? catalog})
    : catalogItems =
          catalog ??
          [
            for (final product in testProducts)
              CatalogProduct(
                id: product.id,
                name: product.name,
                salePriceCents: product.salePriceCents,
                quantity: product.quantity,
                soldByWeight: product.soldByWeight,
              ),
          ];

  final List<CatalogProduct> catalogItems;

  /// Vendas registradas, na ordem em que entraram.
  final List<Sale> sales = [];
  int _nextId = 1;

  @override
  Future<CatalogPage> catalog({required String search, required int offset, required int limit, CancelSignal? cancel}) async {
    final matching = catalogItems.where((product) => product.name.toLowerCase().contains(search.toLowerCase())).toList();
    return CatalogPage(items: matching.skip(offset).take(limit).toList(), total: matching.length);
  }

  @override
  Future<Sale> register(SaleInput input) async {
    final sale = Sale(
      id: 'sale-${_nextId++}',
      createdAt: DateTime.now(),
      items: input.items,
      method: input.method,
      totalCents: _totalOf(input.items),
      customer: input.customer,
    );
    sales.add(sale);
    return sale;
  }

  int historyCalls = 0;

  // Simula o servidor: filtro por dia, forma de pagamento e nome do produto, paginado
  @override
  Future<SaleHistoryPage> history(SaleFilter filter, {required int offset, required int limit, CancelSignal? cancel}) async {
    historyCalls++;
    final from = DateTime(filter.from.year, filter.from.month, filter.from.day);
    final until = DateTime(filter.to.year, filter.to.month, filter.to.day + 1);
    final search = filter.search.trim().toLowerCase();
    final matching =
        sales
            .where((sale) => !sale.createdAt.isBefore(from) && sale.createdAt.isBefore(until))
            .where((sale) => filter.method == null || sale.method == filter.method)
            .where((sale) => search.isEmpty || sale.items.any((item) => item.name.toLowerCase().contains(search)))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return SaleHistoryPage(
      items: matching.skip(offset).take(limit).toList(),
      total: matching.length,
      totalCents: matching.fold(0, (sum, sale) => sum + sale.totalCents),
    );
  }

  @override
  Future<Sale> get(String id) async => _find(id);

  @override
  Future<Sale> update(String id, SaleInput input, {required DateTime createdAt}) async {
    final original = _find(id);
    final updated = Sale(
      id: id,
      createdAt: createdAt,
      items: input.items,
      method: input.method,
      totalCents: _totalOf(input.items),
      editedAt: DateTime.now(),
      customer: input.customer,
    );
    sales[sales.indexOf(original)] = updated;
    return updated;
  }

  Sale _find(String id) => sales.firstWhere((sale) => sale.id == id, orElse: () => throw const ServerFailure());

  int _totalOf(List<SaleItem> items) => items.fold(0, (sum, item) => sum + item.subtotalCents);
}

/// Relatório fixo com um produto de nome longo e um com prejuízo, para os testes de layout.
class FakeReportsRepository implements ReportsRepository {
  @override
  Future<SalesReport> salesReport({required DateTime from, required DateTime to}) async => const SalesReport(
    saleCount: 12,
    revenueCents: 125090,
    costCents: 80050,
    profitCents: 45040,
    ranking: [
      ReportRankingItem(
        name: 'Arroz Tipo 1 Pacote de Cinco Quilos',
        soldByWeight: false,
        quantity: 14,
        revenueCents: 36260,
        profitCents: 12040,
      ),
      ReportRankingItem(name: 'Tomate', soldByWeight: true, quantity: 3.25, revenueCents: 2600, profitCents: -150),
    ],
  );
}

/// Nome longo de propósito: os testes de layout conferem que não estoura em tela pequena.
const testCustomer = Customer(id: 'c1', name: 'Maria das Graças Oliveira Santos', phone: '+5586999990000', balanceCents: 10345);

/// Clientes em memória, com saldo do fiado e extrato como o servidor faria.
class FakeCustomersRepository implements CustomersRepository {
  FakeCustomersRepository({List<Customer>? customers}) : customers = customers ?? [];

  final List<Customer> customers;
  final Map<String, List<StatementEntry>> statements = {};
  int _nextId = 1;

  @override
  Future<CustomerPage> list({
    required String search,
    required CustomerBalanceFilter balance,
    required int offset,
    required int limit,
    CancelSignal? cancel,
  }) async {
    final query = search.toLowerCase();
    final matching =
        customers
            .where((customer) => balance == CustomerBalanceFilter.all || customer.owes)
            .where((customer) => customer.name.toLowerCase().contains(query) || customer.phone.contains(query))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    final owing = customers.where((customer) => customer.owes);
    return CustomerPage(
      items: matching.skip(offset).take(limit).toList(),
      total: matching.length,
      summary: CreditSummary(owingCount: owing.length, owedCents: owing.fold(0, (sum, customer) => sum + customer.balanceCents)),
    );
  }

  @override
  Future<Customer> get(String id) async => customers.firstWhere((customer) => customer.id == id);

  @override
  Future<Customer> create(CustomerInput input) async {
    final customer = Customer(id: 'customer-${_nextId++}', name: input.name, phone: input.phone, balanceCents: 0);
    customers.add(customer);
    return customer;
  }

  @override
  Future<StatementPage> statement(String customerId, {required int offset, required int limit}) async {
    final entries = statements[customerId] ?? const [];
    return StatementPage(items: entries.skip(offset).take(limit).toList(), total: entries.length);
  }

  @override
  Future<int> registerPayment(String customerId, {required int amountCents, required SettlementMethod method}) async {
    final index = customers.indexWhere((customer) => customer.id == customerId);
    final customer = customers[index];
    if (amountCents > customer.balanceCents) {
      throw const RequestFailure(statusCode: 409, message: 'O pagamento passa da dívida do cliente.');
    }
    final balance = customer.balanceCents - amountCents;
    customers[index] = customer.copyWith(balanceCents: balance);
    statements
        .putIfAbsent(customerId, () => [])
        .insert(
          0,
          StatementEntry(
            kind: StatementEntryKind.payment,
            id: 'payment-${_nextId++}',
            amountCents: amountCents,
            createdAt: DateTime.now(),
            settlementMethod: method,
          ),
        );
    return balance;
  }
}

SaleCartController saleCartFor(SalesRepository repository) => SaleCartController(repository, StockChanges());
