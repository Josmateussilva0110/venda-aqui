import 'package:flutter/foundation.dart';

import '../../../../core/network/app_failure.dart';
import '../../../../core/utils/dispose_aware_notifier.dart';
import '../../domain/store.dart';
import '../../domain/stores_repository.dart';

sealed class StoresState {
  const StoresState();
}

final class StoresLoading extends StoresState {
  const StoresLoading();
}

final class StoresFailed extends StoresState {
  const StoresFailed(this.failure);
  final AppFailure failure;
}

final class StoresLoaded extends StoresState {
  const StoresLoaded(this.stores);
  final List<Store> stores;
}

/// Lojas ligadas ao acesso. São poucas por pessoa (uma por loja onde compra), por isso vêm sem paginação.
class StoresController extends ChangeNotifier with DisposeAwareNotifier {
  StoresController(this._repository);

  final StoresRepository _repository;

  StoresState _state = const StoresLoading();

  StoresState get state => _state;

  /// [silent] mantém a lista na tela enquanto atualiza (puxar para baixo).
  Future<void> load({bool silent = false}) async {
    if (!silent || _state is! StoresLoaded) _set(const StoresLoading());
    try {
      _set(StoresLoaded(await _repository.listStores()));
    } on AppFailure catch (failure) {
      _set(StoresFailed(failure));
    }
  }

  void _set(StoresState state) {
    _state = state;
    notifyListeners();
  }
}
