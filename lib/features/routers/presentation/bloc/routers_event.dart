part of 'routers_bloc.dart';

sealed class RoutersEvent extends Equatable {
  const RoutersEvent();

  @override
  List<Object> get props => [];
}

class RoutersLoadRequested extends RoutersEvent {
  const RoutersLoadRequested();
}

class RouterAddRequested extends RoutersEvent {
  final MikroTikRouter router;
  const RouterAddRequested(this.router);

  @override
  List<Object> get props => [router];
}

class RouterUpdateRequested extends RoutersEvent {
  final MikroTikRouter router;
  const RouterUpdateRequested(this.router);

  @override
  List<Object> get props => [router];
}

class RouterDeleteRequested extends RoutersEvent {
  final int id;
  const RouterDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class RouterSelected extends RoutersEvent {
  final MikroTikRouter router;
  const RouterSelected(this.router);

  @override
  List<Object> get props => [router];
}
