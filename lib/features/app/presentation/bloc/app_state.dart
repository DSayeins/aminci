part of 'app_bloc.dart';

sealed class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

/// État initial — avant que l'utilisateur soit chargé.
final class AppInitial extends AppState {}

/// Navigation active — pages filtrées selon le rôle, utilisateur disponible.
final class AppNavigating extends AppState {
  final List<Routes> availablePages;
  final Routes currentPage;
  final User user;

  const AppNavigating({required this.availablePages, required this.currentPage, required this.user});

  AppNavigating copyWith({Routes? currentPage}) =>
      AppNavigating(availablePages: availablePages, currentPage: currentPage ?? this.currentPage, user: user);

  @override
  List<Object> get props => [availablePages, currentPage, user];
}

final class AppClosed extends AppState {}
