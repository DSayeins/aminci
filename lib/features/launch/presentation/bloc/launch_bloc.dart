import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/features/launch/domain/usecases/check_active_session.dart';
import 'package:aminci/features/launch/domain/usecases/check_first_launch.dart';
import 'package:flutter/material.dart';

part 'launch_event.dart';
part 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final CheckFirstLaunch _checkFirstLaunch;
  final CheckActiveSession _checkActiveSession;

  LaunchBloc({required CheckFirstLaunch checkFirstLaunch, required CheckActiveSession checkActiveSession})
    : _checkFirstLaunch = checkFirstLaunch,
      _checkActiveSession = checkActiveSession,
      super(LaunchInitial()) {
    on<LaunchStarted>(_onLaunchStarted);
  }

  Future<void> _onLaunchStarted(LaunchStarted event, Emitter<LaunchState> emit) async {
    debugPrint('[LaunchBloc] LaunchStarted reçu');

    // 1. Premier lancement ?
    final firstLaunchResult = await _checkFirstLaunch();

    final isFirst = firstLaunchResult.fold(
      (failure) => null, // erreur → géré ci-dessous
      (value) => value,
    );

    if (isFirst == null) {
      final msg = firstLaunchResult.fold((f) => f.message, (_) => '');
      debugPrint('[LaunchBloc] Erreur checkFirstLaunch → $msg');
      emit(LaunchError(msg));
      return;
    }

    debugPrint('[LaunchBloc] isFirstLaunch = $isFirst');

    if (isFirst) {
      debugPrint('[LaunchBloc] → LaunchFirstTime');
      emit(LaunchFirstTime());
      return;
    }

    // 2. Session active ?
    final sessionResult = await _checkActiveSession();

    sessionResult.fold(
      (failure) {
        debugPrint('[LaunchBloc] Erreur checkActiveSession → ${failure.message}');
        emit(LaunchError(failure.message));
      },
      (hasSession) {
        debugPrint('[LaunchBloc] hasSession = $hasSession → ${hasSession ? 'LaunchAuthenticated' : 'LaunchUnauthenticated'}');
        emit(hasSession ? LaunchAuthenticated() : LaunchUnauthenticated());
      },
    );
  }
}
