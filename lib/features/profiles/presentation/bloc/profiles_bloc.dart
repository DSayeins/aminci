import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/profiles/domain/usecases/create_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profiles.dart';
import 'package:aminci/features/profiles/domain/usecases/sync_profiles.dart';
import 'package:aminci/features/profiles/domain/usecases/update_price.dart';
import 'package:aminci/features/profiles/domain/usecases/update_profile.dart';
import 'package:aminci/features/routers/domain/usecases/get_routers.dart';

part 'profiles_event.dart';
part 'profiles_state.dart';

class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  final GetProfiles _getProfiles;
  final SyncProfiles _syncProfiles;
  final CreateProfile _createProfile;
  final UpdateProfile _updateProfile;
  final DeleteProfile _deleteProfile;
  final UpdatePrice _updatePrice;
  final GetRouters _getRouters;

  ProfilesBloc({
    required GetProfiles getProfiles,
    required SyncProfiles syncProfiles,
    required CreateProfile createProfile,
    required UpdateProfile updateProfile,
    required DeleteProfile deleteProfile,
    required UpdatePrice updatePrice,
    required GetRouters getRouters,
  })  : _getProfiles = getProfiles,
        _syncProfiles = syncProfiles,
        _createProfile = createProfile,
        _updateProfile = updateProfile,
        _deleteProfile = deleteProfile,
        _updatePrice = updatePrice,
        _getRouters = getRouters,
        super(const ProfilesInitial()) {
    on<ProfilesStarted>(_onStarted);
    on<ProfilesLoaded>(_onLoaded);
    on<ProfilesSynced>(_onSynced);
    on<ProfileCreated>(_onCreated);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileDeleted>(_onDeleted);
    on<ProfilePriceUpdated>(_onPriceUpdated);
  }

  // ---------------------------------------------------------------------------

  Future<void> _onStarted(ProfilesStarted event, Emitter<ProfilesState> emit) async {
    final result = await _getRouters();
    result.fold(
      (failure) => emit(ProfilesError(profiles: const [], message: failure.message)),
      (routers) => emit(ProfilesInitial(routers: routers)),
    );
  }

  Future<void> _onLoaded(ProfilesLoaded event, Emitter<ProfilesState> emit) async {
    emit(ProfilesLoading(routers: state.routers));
    final result = await _getProfiles(event.routerId);
    result.fold(
      (failure) => emit(ProfilesError(profiles: const [], message: failure.message, routers: state.routers)),
      (profiles) => emit(ProfilesListLoaded(profiles: profiles, routerId: event.routerId, routers: state.routers)),
    );
  }

  Future<void> _onSynced(ProfilesSynced event, Emitter<ProfilesState> emit) async {
    final current = state;
    final existing = switch (current) {
      ProfilesListLoaded(:final profiles) => profiles,
      ProfilesOperationSuccess(:final profiles) => profiles,
      ProfilesError(:final profiles) => profiles,
      _ => <HotspotProfile>[],
    };

    emit(ProfilesSyncing(profiles: existing, routers: state.routers));

    final result = await _syncProfiles(event.routerId);
    result.fold(
      (failure) => emit(ProfilesError(profiles: existing, message: failure.message, routers: state.routers)),
      (profiles) => emit(ProfilesOperationSuccess(
        profiles: profiles,
        routerId: event.routerId,
        message: '${profiles.length} profil${profiles.length > 1 ? 's' : ''} synchronisé${profiles.length > 1 ? 's' : ''}',
        routers: state.routers,
      )),
    );
  }

  Future<void> _onCreated(ProfileCreated event, Emitter<ProfilesState> emit) async {
    final existing = switch (state) {
      ProfilesListLoaded(:final profiles) => profiles,
      ProfilesOperationSuccess(:final profiles) => profiles,
      _ => <HotspotProfile>[],
    };

    final result = await _createProfile(
      routerId: event.routerId,
      name: event.name,
      addressPool: event.addressPool,
      rateLimit: event.rateLimit,
      sessionTimeout: event.sessionTimeout,
      idleTimeout: event.idleTimeout,
      keepaliveTimeout: event.keepaliveTimeout,
      addMacCookie: event.addMacCookie,
      macCookieTimeout: event.macCookieTimeout,
      sharedUsers: event.sharedUsers,
      expiresAt: event.expiresAt,
    );
    result.fold(
      (failure) => emit(ProfilesError(profiles: existing, message: failure.message, routers: state.routers)),
      (profile) => emit(ProfilesOperationSuccess(
        profiles: [...existing, profile],
        routerId: event.routerId,
        message: 'Profil "${profile.mikrotikName}" créé',
        routers: state.routers,
      )),
    );
  }

  Future<void> _onUpdated(ProfileUpdated event, Emitter<ProfilesState> emit) async {
    final existing = switch (state) {
      ProfilesListLoaded(:final profiles) => profiles,
      ProfilesOperationSuccess(:final profiles) => profiles,
      _ => <HotspotProfile>[],
    };

    final result = await _updateProfile(
      profileId: event.profileId,
      name: event.name,
      addressPool: event.addressPool,
      rateLimit: event.rateLimit,
      sessionTimeout: event.sessionTimeout,
      idleTimeout: event.idleTimeout,
      keepaliveTimeout: event.keepaliveTimeout,
      addMacCookie: event.addMacCookie,
      macCookieTimeout: event.macCookieTimeout,
      sharedUsers: event.sharedUsers,
      expiresAt: event.expiresAt,
    );
    result.fold(
      (failure) => emit(ProfilesError(profiles: existing, message: failure.message, routers: state.routers)),
      (updated) => emit(ProfilesOperationSuccess(
        profiles: existing.map((p) => p.id == updated.id ? updated : p).toList(),
        routerId: event.routerId,
        message: 'Profil "${updated.mikrotikName}" modifié',
        routers: state.routers,
      )),
    );
  }

  Future<void> _onDeleted(ProfileDeleted event, Emitter<ProfilesState> emit) async {
    final existing = switch (state) {
      ProfilesListLoaded(:final profiles) => profiles,
      ProfilesOperationSuccess(:final profiles) => profiles,
      _ => <HotspotProfile>[],
    };

    final result = await _deleteProfile(event.profileId);
    result.fold(
      (failure) => emit(ProfilesError(profiles: existing, message: failure.message, routers: state.routers)),
      (_) => emit(ProfilesOperationSuccess(
        profiles: existing.where((p) => p.id != event.profileId).toList(),
        routerId: event.routerId,
        message: 'Profil supprimé',
        routers: state.routers,
      )),
    );
  }

  Future<void> _onPriceUpdated(ProfilePriceUpdated event, Emitter<ProfilesState> emit) async {
    final current = state;
    final existing = switch (current) {
      ProfilesListLoaded(:final profiles, :final routerId) => (profiles, routerId),
      ProfilesOperationSuccess(:final profiles, :final routerId) => (profiles, routerId),
      _ => (<HotspotProfile>[], 0),
    };

    final result = await _updatePrice(profileId: event.profileId, price: event.price);
    result.fold(
      (failure) => emit(ProfilesError(profiles: existing.$1, message: failure.message, routers: state.routers)),
      (updated) {
        final updatedList = existing.$1.map((p) => p.id == updated.id ? updated : p).toList();
        emit(ProfilesOperationSuccess(
          profiles: updatedList,
          routerId: existing.$2,
          message: 'Prix mis à jour',
          routers: state.routers,
        ));
      },
    );
  }
}
