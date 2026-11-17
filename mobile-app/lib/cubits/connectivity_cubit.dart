import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  @override
  List<Object?> get props => [];
}

class ConnectivityOnline extends ConnectivityState {}

class ConnectivityDegraded extends ConnectivityState {
  final String reason;
  const ConnectivityDegraded(this.reason);

  @override
  List<Object?> get props => [reason];
}

class ConnectivityOffline extends ConnectivityState {
  final String reason;
  const ConnectivityOffline(this.reason);

  @override
  List<Object?> get props => [reason];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(ConnectivityOnline());

  void setOnline() {
    emit(ConnectivityOnline());
  }

  void setDegraded(String reason) {
    emit(ConnectivityDegraded(reason));
  }

  void setOffline(String reason) {
    emit(ConnectivityOffline(reason));
  }
}
