part of 'routers_bloc.dart';

sealed class RoutersState extends Equatable {
  const RoutersState();

  @override
  List<Object> get props => [];
}

class RoutersInitial extends RoutersState {
  const RoutersInitial();
}

class RoutersLoading extends RoutersState {
  const RoutersLoading();
}

/// Liste chargée. [isBusy] indique qu'une opération (ajout/suppression) est en cours.
/// [selectedRouter] est le routeur actif pour le dashboard.
class RoutersLoaded extends RoutersState {
  final List<MikroTikRouter> routers;
  final bool isBusy;
  final MikroTikRouter? selectedRouter;

  const RoutersLoaded(this.routers, {this.isBusy = false, this.selectedRouter});

  RoutersLoaded copyWith({
    List<MikroTikRouter>? routers,
    bool? isBusy,
    MikroTikRouter? selectedRouter,
  }) =>
      RoutersLoaded(
        routers ?? this.routers,
        isBusy: isBusy ?? this.isBusy,
        selectedRouter: selectedRouter ?? this.selectedRouter,
      );

  @override
  List<Object> get props => [routers, isBusy, if (selectedRouter != null) selectedRouter!];
}

class RoutersError extends RoutersState {
  final String message;
  final List<MikroTikRouter> routers;

  const RoutersError(this.message, {this.routers = const []});

  @override
  List<Object> get props => [message, routers];
}
