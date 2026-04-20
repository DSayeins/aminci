part of 'setup_bloc.dart';

sealed class SetupEvent extends Equatable {
  const SetupEvent();

  @override
  List<Object> get props => [];
}

final class SetupAdminSubmitted extends SetupEvent {
  final String username;
  final String password;

  const SetupAdminSubmitted({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
