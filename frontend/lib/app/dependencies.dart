import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/http_client_factory.dart';
import '../core/security/session_refresher.dart';
import '../core/security/token_store.dart';
import '../core/stock/stock_changes.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/dashboard/data/dashboard_repository_impl.dart';
import '../features/dashboard/domain/stock_overview.dart';
import '../features/products/data/image_picker_photo_picker.dart';
import '../features/products/data/products_remote_data_source.dart';
import '../features/products/data/products_repository_impl.dart';
import '../features/products/domain/photo_picker.dart';
import '../features/products/domain/products_repository.dart';
import '../features/customers/data/customers_repository_impl.dart';
import '../features/customers/domain/customers_repository.dart';
import '../features/reports/data/reports_repository_impl.dart';
import '../features/reports/domain/sales_report.dart';
import '../features/sales/data/catalog_remote_data_source.dart';
import '../features/sales/data/sales_remote_data_source.dart';
import '../features/sales/data/sales_repository_impl.dart';
import '../features/sales/domain/sales_repository.dart';
import '../features/sales/presentation/controllers/sale_cart_controller.dart';

/// Tudo que acessa rede, armazenamento ou plugins é criado aqui e injetado por Provider,
/// para os testes trocarem por versões falsas.
class AppDependencies {
  AppDependencies({
    required this.authRepository,
    required this.productsRepository,
    required this.dashboardRepository,
    required this.photoPicker,
    required this.sessionController,
    required this.stockChanges,
    required this.themeController,
    required this.salesRepository,
    required this.saleCart,
    required this.customersRepository,
    required this.reportsRepository,
  });

  final AuthRepository authRepository;
  final ProductsRepository productsRepository;
  final DashboardRepository dashboardRepository;
  final PhotoPicker photoPicker;
  final SessionController sessionController;
  final StockChanges stockChanges;
  final ThemeController themeController;
  final SalesRepository salesRepository;

  /// Venda em andamento: sobrevive à navegação entre vender, peso, resumo e pagamento.
  final SaleCartController saleCart;
  final CustomersRepository customersRepository;
  final ReportsRepository reportsRepository;

  factory AppDependencies.create(AppConfig config, {required ThemeController themeController}) {
    final tokenStore = TokenStore(const FlutterSecureStorage());
    final plainClient = HttpClientFactory.create(config);
    final refresher = SessionRefresher(plainClient: plainClient, tokenStore: tokenStore);

    // O interceptor precisa avisar a sessão, que por sua vez depende do repositório: liga depois
    late final SessionController session;
    final apiDio = HttpClientFactory.create(config)
      ..interceptors.add(
        AuthInterceptor(
          tokenStore: tokenStore,
          retryClient: plainClient,
          refreshSession: refresher.refresh,
          onSessionEnded: () => session.sessionEnded(),
        ),
      );
    configureApi(apiDio);
    final storageClient = Dio(
      BaseOptions(connectTimeout: config.httpTimeout, sendTimeout: config.httpTimeout, receiveTimeout: config.httpTimeout),
    );

    final authRepository = AuthRepositoryImpl(remote: const AuthRemoteDataSource(), tokenStore: tokenStore, refresher: refresher);
    session = SessionController(authRepository);
    final salesRepository = SalesRepositoryImpl(const CatalogRemoteDataSource(), const SalesRemoteDataSource());
    final stockChanges = StockChanges();
    final saleCart = SaleCartController(salesRepository, stockChanges);
    // Sair da conta descarta a venda em andamento, para o próximo login não herdar o carrinho
    session.addListener(() {
      if (session.status == SessionStatus.signedOut) saleCart.clear();
    });

    return AppDependencies(
      authRepository: authRepository,
      productsRepository: ProductsRepositoryImpl(ProductsRemoteDataSource(storageClient: storageClient)),
      dashboardRepository: const DashboardRepositoryImpl(),
      photoPicker: ImagePickerPhotoPicker(),
      sessionController: session,
      stockChanges: stockChanges,
      themeController: themeController,
      salesRepository: salesRepository,
      saleCart: saleCart,
      customersRepository: const CustomersRepositoryImpl(),
      reportsRepository: const ReportsRepositoryImpl(),
    );
  }

  List<SingleChildWidget> get providers => [
    Provider<AuthRepository>.value(value: authRepository),
    Provider<ProductsRepository>.value(value: productsRepository),
    Provider<DashboardRepository>.value(value: dashboardRepository),
    Provider<PhotoPicker>.value(value: photoPicker),
    Provider<StockChanges>.value(value: stockChanges),
    ChangeNotifierProvider<SessionController>.value(value: sessionController),
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
    Provider<SalesRepository>.value(value: salesRepository),
    ChangeNotifierProvider<SaleCartController>.value(value: saleCart),
    Provider<CustomersRepository>.value(value: customersRepository),
    Provider<ReportsRepository>.value(value: reportsRepository),
  ];
}
