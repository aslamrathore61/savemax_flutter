import 'package:flutter/cupertino.dart';

import '../model/native_item.dart';

@immutable
abstract class NativeItemState {}

class NativeItemInitial extends NativeItemState {}

class NativeItemLoaded extends NativeItemState {
  final NativeItem nativeItem;

  NativeItemLoaded(this.nativeItem);
}

class NativeItemError extends NativeItemState {
  final String message;

  NativeItemError(this.message);
}
