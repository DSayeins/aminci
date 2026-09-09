import 'package:equatable/equatable.dart';

/// État applicatif persisté — table `app_state` (au plus 1 ligne, id = 1).
/// Sert notamment à déterminer si l'application a déjà été lancée.
class AppState extends Equatable {
  final bool firstLaunchDone;

  const AppState({required this.firstLaunchDone});

  AppState copyWith({bool? firstLaunchDone}) {
    return AppState(firstLaunchDone: firstLaunchDone ?? this.firstLaunchDone);
  }

  Map<String, dynamic> toMap() {
    return {'first_launch_done': firstLaunchDone ? 1 : 0};
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(firstLaunchDone: (map['first_launch_done'] as int? ?? 0) == 1);
  }

  @override
  List<Object> get props => [firstLaunchDone];
}
