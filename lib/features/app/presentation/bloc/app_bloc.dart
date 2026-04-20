import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:aminci/core/navigation/routes.dart';
import 'package:aminci/features/app/domain/usecases/get_user.dart';
import 'package:aminci/features/app/domain/usecases/logout.dart';
import 'package:aminci/features/auth/domain/entities/user.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GetUser _getUser;
  final Logout _logout;

  AppBloc({required GetUser getUser, required Logout logout})
      : _getUser = getUser,
        _logout = logout,
        super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<NavigateTo>(_onNavigateTo);
    on<AppLogoutRequested>(_onLogoutRequested);
    on<ResetNavigation>(_onResetNavigation);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    final result = await _getUser();

    result.fold(
      (failure) {
        debugPrint('[AppBloc] Impossible de charger l\'utilisateur actif : ${failure.message}');
        emit(AppInitial());
      },
      (user) {
        debugPrint('[AppBloc] Utilisateur actif = ${user.username} (${user.role.name})');
        final pages = user.isAdmin ? RoutesExtension.forAdmin() : RoutesExtension.forOperator();
        debugPrint('[AppBloc] Pages disponibles = ${pages.map((p) => p.name).join(', ')}');
        emit(AppNavigating(availablePages: pages, currentPage: pages.first, user: user));
      },
    );
  }

  void _onNavigateTo(NavigateTo event, Emitter<AppState> emit) {
    final current = state;
    if (current is! AppNavigating) return;
    if (!current.availablePages.contains(event.page)) return;
    emit(current.copyWith(currentPage: event.page));
  }

  Future<void> _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) async {
    await _logout();
    debugPrint('[AppBloc] Logout → AppClosed');
    emit(AppClosed());
  }

  void _onResetNavigation(ResetNavigation event, Emitter<AppState> emit) {
    emit(AppInitial());
  }
}
