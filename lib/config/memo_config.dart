import 'package:flutter/material.dart';

class MemoConfig {
  static final ValueNotifier<bool> showHeatMap = ValueNotifier<bool>(false);

  static void toggleHeatMap() {
    !showHeatMap.value ? print('heatmap open.') : print('heatmap close.');
    showHeatMap.value = !showHeatMap.value;
  }
}
