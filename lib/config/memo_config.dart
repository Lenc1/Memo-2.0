import 'package:flutter/material.dart';

class MemoConfig {
  static final ValueNotifier<bool> showHeatMap = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> refresh = ValueNotifier<bool>(true);
  static void toggleRefresh(){
    refresh.value = !refresh.value;
  }
  static void toggleHeatMap() {
    !showHeatMap.value ? print('heatmap open.') : print('heatmap close.');
    showHeatMap.value = !showHeatMap.value;
  }
}
