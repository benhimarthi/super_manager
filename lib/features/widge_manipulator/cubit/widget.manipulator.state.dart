import 'package:equatable/equatable.dart';

class WidgetManipulatorState extends Equatable {
  const WidgetManipulatorState();
  @override
  List<Object?> get props => [];
}

class WidgetManipulatorInitial extends WidgetManipulatorState {}

class ChangeMenuSuccessfully extends WidgetManipulatorState {
  final double position;
  final String title;
  const ChangeMenuSuccessfully(this.position, this.title);
}
