import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/user.dart';
import 'package:aminci/features/login/domain/usecases/login.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Login _login;

  LoginBloc({required Login login}) : _login = login, super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoginSessionRestored>((event, emit) => emit(LoginAuthenticated(event.user)));
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    final result = await _login(username: event.username, password: event.password);
    result.fold((failure) => emit(LoginError(failure.message)), (user) => emit(LoginAuthenticated(user)));
  }
}
