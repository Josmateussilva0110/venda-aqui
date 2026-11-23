import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/network/http_client_factory.dart';
import '../core/security/session_refresher.dart';
import '../core/security/token_store.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../features/stores/data/stores_remote_data_source.dart';
import '../features/stores/data/stores_repository_impl.dart';
import '../features/stores/domain/stores_repository.dart';

/// Tudo que acessa rede ou armazenamento é criado aqui e injetado por Provider,
/// para os testes trocarem por versões falsas.
class AppDependencies {
  AppDependencies({
    required this.authRepository,
    required this.storesRepository,
    required this.sessionController,
    required this.themeController,
  });

  final AuthRepository authRepository;
  final StoresRepository storesRepository;
  final SessionController sessionController;
  final ThemeController themeController;

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

    final authRepository = AuthRepositoryImpl(remote: const AuthRemoteDataSource(), tokenStore: tokenStore, refresher: refresher);
    session = SessionController(authRepository);
    return AppDependencies(
      authRepository: authRepository,
      storesRepository: const StoresRepositoryImpl(StoresRemoteDataSource()),
      sessionController: session,
      themeController: themeController,
    );
  }

  List<SingleChildWidget> get providers => [
    Provider<AuthRepository>.value(value: authRepository),
    Provider<StoresRepository>.value(value: storesRepository),
    ChangeNotifierProvider<SessionController>.value(value: sessionController),
    ChangeNotifierProvider<ThemeController>.value(value: themeController),
  ];
}
