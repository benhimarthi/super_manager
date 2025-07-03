import 'package:bloc/bloc.dart';

import 'widget.manipulator.state.dart';

class WidgetManipulatorCubit extends Cubit<WidgetManipulatorState> {
  WidgetManipulatorCubit() : super(WidgetManipulatorInitial());
  Future<void> changeMenu(double position, String nameMenu) async {
    emit(WidgetManipulatorInitial());
    emit(ChangeMenuSuccessfully(position, nameMenu));
  }
}
