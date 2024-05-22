import 'package:bloc/bloc.dart';
import '../Network/ApiProvider.dart';
import 'native_item_event.dart';
import 'native_item_state.dart';

class NativeItemBloc extends Bloc<NativeItemEvent, NativeItemState> {
  final ApiProvider _apiRepository = ApiProvider();

  NativeItemBloc() : super(NativeItemInitial()) {
    on<GetMenuDetailsEvents>((event, emit) async {
      try {
        final mList = await _apiRepository.fetchMenuDetails();
        print('prinListaaa ${mList.toJson()}');

        if (mList != null) {
          emit(NativeItemLoaded(mList));
        } else {
          print('erorEMIT error}');
          emit(NativeItemError('List Getting empty'));
        }
      } catch (error) {
        emit(NativeItemError(error.toString()));
      }
    });
  }
}
