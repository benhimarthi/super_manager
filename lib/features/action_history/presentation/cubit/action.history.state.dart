import 'package:equatable/equatable.dart';
import '../../domain/entities/action.history.dart';

abstract class ActionHistoryState extends Equatable {
  const ActionHistoryState();
  @override
  List<Object> get props => [];
}

class ActionHistoryManagerInitial extends ActionHistoryState {}

class ActionHistoryManagerLoading extends ActionHistoryState {}

class ActionHistoryManagerLoaded extends ActionHistoryState {
  final List<ActionHistory> historyList;
  const ActionHistoryManagerLoaded(this.historyList);
  @override
  List<Object> get props => [historyList];
}

class ActionHistoryManagerError extends ActionHistoryState {
  final String message;
  const ActionHistoryManagerError(this.message);
  @override
  List<Object> get props => [message];
}
