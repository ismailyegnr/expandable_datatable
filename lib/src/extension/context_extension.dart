import 'package:flutter/material.dart';

import '../utility/expandable_theme.dart';
import '../utility/expandable_theme_data.dart';

extension ContextExtension on BuildContext {
  ExpandableThemeData get expandableTheme => ExpandableTheme.of(this);

  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;

  double get lowValue => height * 0.01;
  double get normalValue => height * 0.02;
  double get mediumValue => height * 0.04;
  double get highValue => height * 0.1;

  double dynamicWidth(double val) => width * val;
  double dynamicHeight(double val) => height * val;
}
