import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/hotspot.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/features/hotspot/domain/usecases/get_hotspots.dart';

part 'hotspot_event.dart';
part 'hotspot_state.dart';

class HotspotBloc extends Bloc<HotspotEvent, HotspotState> {
  final GetHotspots _getHotspots;

  HotspotBloc({required GetHotspots getHotspots}) : _getHotspots = getHotspots, super(const HotspotInitial()) {
    on<HotspotsLoadRequested>(_onLoadRequested);
    on<HotspotSelected>(_onSelected);
  }

  Future<void> _onLoadRequested(HotspotsLoadRequested event, Emitter<HotspotState> emit) async {
    emit(const HotspotLoading());
    final result = await _getHotspots(event.router);
    result.fold(
      (failure) => emit(HotspotError(failure.message)),
      (hotspots) => emit(HotspotLoaded(hotspots)),
    );
  }

  void _onSelected(HotspotSelected event, Emitter<HotspotState> emit) {
    if (state is! HotspotLoaded) return;
    emit((state as HotspotLoaded).copyWith(selected: event.hotspot));
  }
}
