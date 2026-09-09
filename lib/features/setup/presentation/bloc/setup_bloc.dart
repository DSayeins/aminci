import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';
import 'package:aminci/features/setup/domain/usecases/create_setup.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final CreateSetup _create;

  SetupBloc({required CreateSetup createSetup}) : _create = createSetup, super(const SetupInitial()) {
    on<SetupStepChanged>((event, emit) => emit(SetupInProgress(event.step)));
    on<SetupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(SetupSubmitted event, Emitter<SetupState> emit) async {
    emit(SetupLoading(state.currentStep));

    final result = await _create(user: event.user, router: event.router, preference: event.preference);

    result.fold(
      (failure) => emit(SetupError(failure.message, state.currentStep)),
      (_) => emit(SetupSuccess(state.currentStep)),
    );
  }
}
