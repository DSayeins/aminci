part of 'profile_users_cubit.dart';

sealed class ProfileUsersState {
  const ProfileUsersState();
}

final class ProfileUsersInitial extends ProfileUsersState {
  const ProfileUsersInitial();
}

final class ProfileUsersLoading extends ProfileUsersState {
  const ProfileUsersLoading();
}

final class ProfileUsersLoaded extends ProfileUsersState {
  final List<Voucher> vouchers;
  final bool isDeleting;

  const ProfileUsersLoaded(this.vouchers, {this.isDeleting = false});
}

final class ProfileUsersError extends ProfileUsersState {
  final String message;
  const ProfileUsersError(this.message);
}
