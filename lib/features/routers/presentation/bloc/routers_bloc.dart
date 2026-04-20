import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/routers/domain/usecases/add_router.dart';
import 'package:aminci/features/routers/domain/usecases/delete_router.dart';
import 'package:aminci/features/routers/domain/usecases/get_routers.dart';
import 'package:aminci/features/routers/domain/usecases/test_connection.dart';
import 'package:aminci/features/routers/domain/usecases/update_router.dart';

part 'routers_event.dart';
part 'routers_state.dart';

class RoutersBloc extends Bloc<RoutersEvent, RoutersState> {
  final GetRouters _getRouters;
  final AddRouter _addRouter;
  final UpdateRouter _updateRouter;
  final DeleteRouter _deleteRouter;
  final TestConnection _testConnection;

  RoutersBloc({
    required GetRouters getRouters,
    required AddRouter addRouter,
    required UpdateRouter updateRouter,
    required DeleteRouter deleteRouter,
    required TestConnection testConnection,
  })  : _getRouters = getRouters,
        _addRouter = addRouter,
        _updateRouter = updateRouter,
        _deleteRouter = deleteRouter,
        _testConnection = testConnection,
        super(RoutersInitial()) {
    on<RoutersLoaded>(_onLoaded);
    on<RouterAdded>(_onAdded);
    on<RouterUpdated>(_onUpdated);
    on<RouterDeleted>(_onDeleted);
    on<RouterConnectionTested>(_onConnectionTested);
  }

  // ---------------------------------------------------------------------------

  Future<void> _onLoaded(RoutersLoaded event, Emitter<RoutersState> emit) async {
    emit(RoutersLoading());
    final result = await _getRouters();
    result.fold(
      (failure) => emit(RoutersError(failure.message)),
      (routers) => emit(RoutersListLoaded(routers)),
    );
  }

  Future<void> _onAdded(RouterAdded event, Emitter<RoutersState> emit) async {
    emit(RoutersLoading());
    final result = await _addRouter(
      name: event.name,
      ip: event.ip,
      port: event.port,
      username: event.username,
      password: event.password,
      rosVersion: event.rosVersion,
    );
    await result.fold(
      (failure) async => emit(RoutersError(failure.message)),
      (_) async {
        final listResult = await _getRouters();
        listResult.fold(
          (failure) => emit(RoutersError(failure.message)),
          (routers) => emit(RoutersOperationSuccess(
            routers: routers,
            message: 'Routeur ajouté avec succès',
          )),
        );
      },
    );
  }

  Future<void> _onUpdated(RouterUpdated event, Emitter<RoutersState> emit) async {
    emit(RoutersLoading());
    final result = await _updateRouter(
      id: event.id,
      name: event.name,
      ip: event.ip,
      port: event.port,
      username: event.username,
      password: event.password,
      rosVersion: event.rosVersion,
    );
    await result.fold(
      (failure) async => emit(RoutersError(failure.message)),
      (_) async {
        final listResult = await _getRouters();
        listResult.fold(
          (failure) => emit(RoutersError(failure.message)),
          (routers) => emit(RoutersOperationSuccess(
            routers: routers,
            message: 'Routeur modifié avec succès',
          )),
        );
      },
    );
  }

  Future<void> _onDeleted(RouterDeleted event, Emitter<RoutersState> emit) async {
    emit(RoutersLoading());
    final result = await _deleteRouter(event.id);
    await result.fold(
      (failure) async => emit(RoutersError(failure.message)),
      (_) async {
        final listResult = await _getRouters();
        listResult.fold(
          (failure) => emit(RoutersError(failure.message)),
          (routers) => emit(RoutersOperationSuccess(
            routers: routers,
            message: 'Routeur supprimé',
          )),
        );
      },
    );
  }

  Future<void> _onConnectionTested(
    RouterConnectionTested event,
    Emitter<RoutersState> emit,
  ) async {
    final current = state;
    final routers = switch (current) {
      RoutersListLoaded(:final routers) => routers,
      RoutersOperationSuccess(:final routers) => routers,
      RouterConnectionResult(:final routers) => routers,
      _ => <MikroTikRouter>[],
    };

    emit(RouterTestingConnection(routers: routers, routerId: event.id));

    final result = await _testConnection(event.id);
    result.fold(
      (failure) => emit(RouterConnectionResult(
        routers: routers,
        routerId: event.id,
        success: false,
        message: failure.message,
      )),
      (_) => emit(RouterConnectionResult(
        routers: routers,
        routerId: event.id,
        success: true,
        message: 'Connexion établie',
      )),
    );
  }
}
