import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/features/auth/domain/entities/user.dart';
import 'package:aminci/features/auth/domain/usecases/change_password.dart';
import 'package:aminci/features/auth/domain/usecases/login.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login _login;
  final ChangePassword _changePassword;

  AuthBloc({required Login login, required ChangePassword changePassword})
    : _login = login,
      _changePassword = changePassword,
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthPasswordChanged>(_onPasswordChanged);
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _login(username: event.username, password: event.password);
    result.fold((failure) => emit(AuthError(failure.message)), (user) => emit(AuthAuthenticated(user)));
  }

  Future<void> _onPasswordChanged(AuthPasswordChanged event, Emitter<AuthState> emit) async {
    final current = state;
    final result = await _changePassword(userId: event.userId, newPassword: event.newPassword);
    result.fold((failure) => emit(AuthError(failure.message)), (_) => emit(current));
  }
}
