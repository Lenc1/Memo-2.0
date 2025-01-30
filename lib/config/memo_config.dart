import 'package:flutter/material.dart';

class MemoConfig {
  static final ValueNotifier<bool> showHeatMap = ValueNotifier<bool>(true);

  static void toggleHeatMap() {
    !showHeatMap.value ? print('heatmap open.') : print('heatmap close.');
    showHeatMap.value = !showHeatMap.value;
  }
}
