import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/usecases/add_router.dart';
import 'package:aminci/features/routers/domain/usecases/delete_router.dart';
import 'package:aminci/features/routers/domain/usecases/get_routers.dart';
import 'package:aminci/features/routers/domain/usecases/update_router.dart';

part 'routers_event.dart';
part 'routers_state.dart';

class RoutersBloc extends Bloc<RoutersEvent, RoutersState> {
  final GetRouters _getRouters;
  final AddRouter _addRouter;
  final UpdateRouter _updateRouter;
  final DeleteRouter _deleteRouter;

  RoutersBloc({
    required GetRouters getRouters,
    required AddRouter addRouter,
    required UpdateRouter updateRouter,
    required DeleteRouter deleteRouter,
  })  : _getRouters = getRouters,
        _addRouter = addRouter,
        _updateRouter = updateRouter,
        _deleteRouter = deleteRouter,
        super(const RoutersInitial()) {
    on<RoutersLoadRequested>(_onLoad);
    on<RouterAddRequested>(_onAdd);
    on<RouterUpdateRequested>(_onUpdate);
    on<RouterDeleteRequested>(_onDelete);
    on<RouterSelected>(_onSelected);
  }

  Future<void> _onLoad(RoutersLoadRequested event, Emitter<RoutersState> emit) async {
    emit(const RoutersLoading());
    final result = await _getRouters();
    result.fold(
      (failure) => emit(RoutersError(failure.message)),
      (routers) => emit(RoutersLoaded(routers)),
    );
  }

  Future<void> _onAdd(RouterAddRequested event, Emitter<RoutersState> emit) async {
    final current = state is RoutersLoaded ? (state as RoutersLoaded).routers : <MikroTikRouter>[];
    emit(RoutersLoaded(current, isBusy: true));

    final result = await _addRouter(event.router);
    result.fold(
      (failure) => emit(RoutersError(failure.message, routers: current)),
      (router) => emit(RoutersLoaded([...current, router])),
    );
  }

  Future<void> _onUpdate(RouterUpdateRequested event, Emitter<RoutersState> emit) async {
    final loaded = state is RoutersLoaded ? state as RoutersLoaded : null;
    final current = loaded?.routers ?? <MikroTikRouter>[];
    emit(RoutersLoaded(current, isBusy: true, selectedRouter: loaded?.selectedRouter));

    final result = await _updateRouter(event.router);
    result.fold(
      (failure) => emit(RoutersError(failure.message, routers: current)),
      (updated) {
        final routers = current.map((r) => r.id == updated.id ? updated : r).toList();
        final selected = loaded?.selectedRouter?.id == updated.id ? updated : loaded?.selectedRouter;
        emit(RoutersLoaded(routers, selectedRouter: selected));
      },
    );
  }

  Future<void> _onDelete(RouterDeleteRequested event, Emitter<RoutersState> emit) async {
    final loaded = state is RoutersLoaded ? state as RoutersLoaded : null;
    final current = loaded?.routers ?? <MikroTikRouter>[];
    emit(RoutersLoaded(current, isBusy: true, selectedRouter: loaded?.selectedRouter));

    final result = await _deleteRouter(event.id);
    result.fold(
      (failure) => emit(RoutersError(failure.message, routers: current)),
      (_) {
        final remaining = current.where((r) => r.id != event.id).toList();
        final selected = loaded?.selectedRouter?.id == event.id ? null : loaded?.selectedRouter;
        emit(RoutersLoaded(remaining, selectedRouter: selected));
      },
    );
  }

  void _onSelected(RouterSelected event, Emitter<RoutersState> emit) {
    if (state is! RoutersLoaded) return;
    emit((state as RoutersLoaded).copyWith(selectedRouter: event.router));
  }
}
