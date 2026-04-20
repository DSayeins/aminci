import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/features/setup/domain/usecases/create_admin_account.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final CreateAdminAccount _createAdminAccount;

  SetupBloc({required CreateAdminAccount createAdminAccount})
      : _createAdminAccount = createAdminAccount,
        super(SetupInitial()) {
    on<SetupAdminSubmitted>(_onAdminSubmitted);
  }

  Future<void> _onAdminSubmitted(
    SetupAdminSubmitted event,
    Emitter<SetupState> emit,
  ) async {
    emit(SetupLoading());

    final result = await _createAdminAccount(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(SetupError(failure.message)),
      (_) => emit(SetupSuccess()),
    );
  }
}
