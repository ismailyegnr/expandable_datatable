import 'package:flutter/material.dart';

import '../utility/expandable_theme.dart';

extension ContextExtension on BuildContext {
  ExpandableThemeData get expandableTheme => ExpandableTheme.of(this);

  double get height => MediaQuery.of(this).size.height;

  double get lowValue => height * 0.01;
  double get normalValue => height * 0.02;
}
