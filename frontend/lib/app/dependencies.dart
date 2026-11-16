import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/http_client_factory.dart';
import '../core/notifications/local_reminder_notifier.dart';
import '../core/offline/local_database.dart';
import '../core/offline/offline_reader.dart';
import '../core/offline/offline_status.dart';
import '../core/offline/offline_store.dart';
import '../core/offline/offline_sync.dart';
import '../core/offline/offline_writer.dart';
import '../core/offline/outbox.dart';
import '../core/notifications/reminder_notifier.dart';
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
import '../features/products/data/pending_restock_sender.dart';
import '../features/products/data/products_remote_data_source.dart';
import '../features/products/data/products_repository_impl.dart';
import '../features/products/domain/photo_picker.dart';
import '../features/products/domain/products_repository.dart';
import '../features/customers/data/customers_repository_impl.dart';
import '../features/customers/data/pending_payment_sender.dart';
import '../features/customers/domain/customers_repository.dart';
import '../features/reports/data/reports_repository_impl.dart';
import '../features/reports/domain/sales_report.dart';
import '../features/sales/data/catalog_remote_data_source.dart';
import '../features/sales/data/pending_sale_sender.dart';
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
    required this.reminderNotifier,
    required this.offlineStatus,
    required this.outbox,
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

  /// Aviso no aparelho do dia de lembrar os clientes do fiado.
  final ReminderNotifier reminderNotifier;

  /// Se as telas estão mostrando a cópia local por falta de internet.
  final OfflineStatus offlineStatus;

  /// Vendas, pagamentos de fiado e reposições feitos sem internet esperando para subir.
  final Outbox outbox;

  /// Enquanto houver venda na fila, tenta enviar de tempos em tempos (a internet pode voltar
  /// sem nenhum outro aviso, com o app parado numa tela).
  static const _outboxRetryInterval = Duration(minutes: 1);

  /// Espera depois de descartar uma recusada antes de baixar a cópia de novo (junta descartes seguidos).
  static const _discardRefreshDelay = Duration(seconds: 3);

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

    final localDatabase = LocalDatabase.open();
    final offlineStore = OfflineStore(localDatabase);
    final offlineStatus = OfflineStatus();
    final offlineReader = OfflineReader(offlineStore, offlineStatus);
    final outbox = Outbox(localDatabase, offlineStore);
    // A fila também sabe quando a internet caiu: a próxima gravação vai direto para ela, sem esperar
    void register(String kind, OutboxSender sender) => outbox.register(kind, (payload) async {
      final result = await sender(payload);
      if (result.outcome == OutboxOutcome.retryLater) offlineReader.noteNetworkFailure();
      return result;
    });
    register(PendingSaleSender.kind, const PendingSaleSender().send);
    register(PendingPaymentSender.kind, const PendingPaymentSender().send);
    register(PendingRestockSender.kind, const PendingRestockSender().send);
    final offlineWriter = OfflineWriter(offlineReader, outbox);
    final offlineSync = OfflineSync(store: offlineStore, status: offlineStatus, flushPending: outbox.flush);

    final authRepository = AuthRepositoryImpl(
      remote: const AuthRemoteDataSource(),
      tokenStore: tokenStore,
      refresher: refresher,
      offline: offlineStore,
    );
    session = SessionController(authRepository);
    final salesRepository = SalesRepositoryImpl(
      const CatalogRemoteDataSource(),
      const SalesRemoteDataSource(),
      offlineReader,
      offlineWriter,
    );
    final stockChanges = StockChanges();
    final saleCart = SaleCartController(salesRepository, stockChanges);
    // Sem internet a fila não esvazia: nem tenta baixar a cópia (seria outro timeout inteiro à toa)
    Future<void> sendPendingThenRefresh() async {
      await outbox.refreshCounts();
      if (await outbox.flush()) await offlineSync.refresh();
    }

    var previousStatus = session.status;
    session.addListener(() {
      final status = session.status;
      if (status == previousStatus) return;
      previousStatus = status;
      if (status == SessionStatus.signedIn) unawaited(sendPendingThenRefresh());
      if (status == SessionStatus.signedOut) {
        // Sair da conta descarta a venda em andamento e a cópia local: o próximo login não herda nada.
        // A fila de vendas não enviadas fica (sessão encerrada pelo servidor não pode perder venda)
        saleCart.clear();
        offlineStatus.markOnline();
        unawaited(offlineStore.clear().then((_) => outbox.refreshCounts()));
      }
    });

    var inForeground = true;
    void sendPending() {
      // Em segundo plano não insiste: acordar o rádio a cada minuto gasta bateria, e a volta ao app já envia
      if (inForeground && session.status == SessionStatus.signedIn && outbox.pendingCount > 0) unawaited(outbox.flush());
    }

    // Voltar ao app envia a fila e atualiza a cópia (respeitando o intervalo mínimo entre downloads)
    AppLifecycleListener(
      onStateChange: (state) => inForeground = state == AppLifecycleState.resumed,
      onResume: () {
        if (session.status == SessionStatus.signedIn) unawaited(sendPendingThenRefresh());
      },
    );
    // Uma resposta do servidor depois de um período offline: a internet voltou
    var wasOffline = false;
    offlineStatus.addListener(() {
      if (wasOffline && !offlineStatus.isOffline) sendPending();
      wasOffline = offlineStatus.isOffline;
    });
    Timer.periodic(_outboxRetryInterval, (_) => sendPending());
    // Vendas e reposições da fila mexeram no estoque (e no fiado) do servidor: as telas abertas recarregam
    // uma vez por envio. Só pagamentos não mexem no estoque; o saldo aparece ao abrir o cliente
    // Uma recusada descartada deixou o efeito dela na cópia (ex.: estoque baixado): a cópia vem de novo do
    // servidor. Espera um pouco para vários descartes seguidos custarem um download só
    Timer? discardRefresh;
    outbox.discarded.listen((_) {
      discardRefresh?.cancel();
      discardRefresh = Timer(_discardRefreshDelay, () => unawaited(offlineSync.refresh(force: true)));
    });
    outbox.flushed.listen((kinds) {
      if (kinds.contains(PendingSaleSender.kind) || kinds.contains(PendingRestockSender.kind)) stockChanges.notify(const StockSold());
    });

    return AppDependencies(
      authRepository: authRepository,
      productsRepository: ProductsRepositoryImpl(ProductsRemoteDataSource(storageClient: storageClient), offlineReader, offlineWriter),
      dashboardRepository: DashboardRepositoryImpl(offlineReader),
      photoPicker: ImagePickerPhotoPicker(),
      sessionController: session,
      stockChanges: stockChanges,
      themeController: themeController,
      salesRepository: salesRepository,
      saleCart: saleCart,
      customersRepository: CustomersRepositoryImpl(offlineReader, offlineWriter),
      reportsRepository: const ReportsRepositoryImpl(),
      reminderNotifier: LocalReminderNotifier(),
      offlineStatus: offlineStatus,
      outbox: outbox,
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
    Provider<ReminderNotifier>.value(value: reminderNotifier),
    ChangeNotifierProvider<OfflineStatus>.value(value: offlineStatus),
    ChangeNotifierProvider<Outbox>.value(value: outbox),
  ];
}
