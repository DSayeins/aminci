import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/profiles/domain/usecases/clear_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile_users.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profile_users.dart';

part 'profile_users_state.dart';

class ProfileUsersCubit extends Cubit<ProfileUsersState> {
  final GetProfileUsers _getProfileUsers;
  final DeleteProfileUsers _deleteProfileUsers;
  final ClearProfileUsers _clearProfileUsers;

  int? _routerId;
  String? _profileName;

  ProfileUsersCubit(
    this._getProfileUsers,
    this._deleteProfileUsers,
    this._clearProfileUsers,
  ) : super(const ProfileUsersInitial());

  Future<void> load({required int routerId, required String profileName}) async {
    _routerId = routerId;
    _profileName = profileName;
    emit(const ProfileUsersLoading());
    final result = await _getProfileUsers(routerId: routerId, profileName: profileName);
    result.fold(
      (failure) => emit(ProfileUsersError(failure.message)),
      (vouchers) => emit(ProfileUsersLoaded(vouchers)),
    );
  }

  Future<void> deleteUsers(List<int> voucherIds) async {
    final loaded = state;
    if (loaded is! ProfileUsersLoaded || _routerId == null || _profileName == null) return;

    emit(ProfileUsersLoaded(loaded.vouchers, isDeleting: true));
    final result = await _deleteProfileUsers(routerId: _routerId!, voucherIds: voucherIds);
    await result.fold(
      (failure) async => emit(ProfileUsersError(failure.message)),
      (_) async => load(routerId: _routerId!, profileName: _profileName!),
    );
  }

  Future<void> clearAll() async {
    final loaded = state;
    if (loaded is! ProfileUsersLoaded || _routerId == null || _profileName == null) return;

    emit(ProfileUsersLoaded(loaded.vouchers, isDeleting: true));
    final result = await _clearProfileUsers(routerId: _routerId!, profileName: _profileName!);
    await result.fold(
      (failure) async => emit(ProfileUsersError(failure.message)),
      (_) async => load(routerId: _routerId!, profileName: _profileName!),
    );
  }
}
