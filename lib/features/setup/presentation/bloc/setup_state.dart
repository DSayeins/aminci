part of 'setup_bloc.dart';

sealed class SetupState extends Equatable {
  /// Étape active du wizard (0 = compte admin, 1 = routeur, 2 = préférences).
  final int currentStep;

  const SetupState(this.currentStep);

  @override
  List<Object> get props => [currentStep];
}

final class SetupInitial extends SetupState {
  const SetupInitial() : super(0);
}

/// Navigation entre les étapes du wizard, hors soumission.
final class SetupInProgress extends SetupState {
  const SetupInProgress(super.currentStep);
}

final class SetupLoading extends SetupState {
  const SetupLoading(super.currentStep);
}

final class SetupSuccess extends SetupState {
  const SetupSuccess(super.currentStep);
}

final class SetupError extends SetupState {
  final String message;

  const SetupError(this.message, super.currentStep);

  @override
  List<Object> get props => [message, currentStep];
}
