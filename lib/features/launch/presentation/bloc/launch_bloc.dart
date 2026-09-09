import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/user.dart';
import 'package:aminci/features/launch/domain/entities/launch_result.dart';
import 'package:aminci/features/launch/domain/usecases/initialize.dart';
import 'package:flutter/material.dart';

part 'launch_event.dart';
part 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final Initialize _initialize;

  LaunchBloc({required Initialize initialize})
      : _initialize = initialize,
        super(LaunchInitial()) {
    on<LaunchStarted>(_onLaunchStarted);
  }

  Future<void> _onLaunchStarted(LaunchStarted event, Emitter<LaunchState> emit) async {
    debugPrint('[LaunchBloc] LaunchStarted reçu');

    final result = await _initialize();

    result.fold(
      (failure) {
        debugPrint('[LaunchBloc] Erreur initialize → ${failure.message}');
        emit(LaunchError(failure.message));
      },
      (launchResult) {
        debugPrint('[LaunchBloc] LaunchResult → $launchResult');
        emit(switch (launchResult) {
          LaunchResultFirstLaunch() => LaunchFirstTime(),
          LaunchResultAuthenticated(:final user) => LaunchAuthenticated(user),
          LaunchResultUnauthenticated() => LaunchUnauthenticated(),
        });
      },
    );
  }
}
