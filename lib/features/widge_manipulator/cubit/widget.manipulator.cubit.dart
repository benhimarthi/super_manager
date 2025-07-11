import 'package:bloc/bloc.dart';

import '../../product/domain/entities/product.dart';
import 'widget.manipulator.state.dart';

class WidgetManipulatorCubit extends Cubit<WidgetManipulatorState> {
  WidgetManipulatorCubit() : super(WidgetManipulatorInitial());
  Future<void> changeMenu(double position, String nameMenu) async {
    emit(WidgetManipulatorInitial());
    emit(ChangeMenuSuccessfully(position, nameMenu));
  }

  Future<void> selectProductCategory(String title, String categoryUid) async {
    emit(WidgetManipulatorInitial());
    emit(
      SelectingProductCategorySuccessfully(
        categoryName: title,
        categoryuid: categoryUid,
      ),
    );
  }

  Future<void> cacheProduct(Product product) async {
    emit(WidgetManipulatorInitial());
    emit(CacheProductSuccessfully(product));
  }

  Future<void> selectCurrency(String currency, String country) async {
    emit(WidgetManipulatorInitial());
    emit(SelectingCurrencySuccessfully(currency, country));
  }

  Future<void> addELement(String pricingId) async {
    emit(WidgetManipulatorInitial());
    emit(ElementAddedSuccessfully(pricingId));
  }
}
