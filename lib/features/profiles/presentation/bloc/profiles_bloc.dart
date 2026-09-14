import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/profiles/domain/usecases/create_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/delete_profile.dart';
import 'package:aminci/features/profiles/domain/usecases/get_profiles.dart';

part 'profiles_event.dart';
part 'profiles_state.dart';

class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  final GetProfiles _getProfiles;
  final CreateProfile _createProfile;
  final DeleteProfile _deleteProfile;

  ProfilesBloc({
    required GetProfiles getProfiles,
    required CreateProfile createProfile,
    required DeleteProfile deleteProfile,
  })  : _getProfiles = getProfiles,
        _createProfile = createProfile,
        _deleteProfile = deleteProfile,
        super(const ProfilesInitial()) {
    on<ProfilesLoadRequested>(_onLoadRequested);
    on<ProfileCreateRequested>(_onCreateRequested);
    on<ProfileDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(ProfilesLoadRequested event, Emitter<ProfilesState> emit) async {
    emit(const ProfilesLoading());
    final result = await _getProfiles(event.router);
    result.fold(
      (failure) => emit(ProfilesError(failure.message)),
      (profiles) => emit(ProfilesLoaded(profiles)),
    );
  }

  Future<void> _onCreateRequested(ProfileCreateRequested event, Emitter<ProfilesState> emit) async {
    final current = state is ProfilesLoaded ? (state as ProfilesLoaded).profiles : <HotspotProfile>[];
    emit(ProfilesLoaded(current, isBusy: true));

    final result = await _createProfile(event.router, event.profile);
    result.fold(
      (failure) => emit(ProfilesError(failure.message, profiles: current)),
      (profile) => emit(ProfilesLoaded([...current, profile])),
    );
  }

  Future<void> _onDeleteRequested(ProfileDeleteRequested event, Emitter<ProfilesState> emit) async {
    final current = state is ProfilesLoaded ? (state as ProfilesLoaded).profiles : <HotspotProfile>[];
    emit(ProfilesLoaded(current, isBusy: true));

    final result = await _deleteProfile(event.router, event.profile);
    result.fold(
      (failure) => emit(ProfilesError(failure.message, profiles: current)),
      (_) => emit(ProfilesLoaded(current.where((p) => p.id != event.profile.id).toList())),
    );
  }
}
