import 'package:flutter/material.dart';

import '../../expandable_datatable.dart';

class ExpandableTheme extends InheritedWidget {
  final ExpandableThemeData data;

  const ExpandableTheme({
    super.key,
    required this.data,
    required ExpandableDataTable super.child,
  });

  static ExpandableThemeData of(BuildContext context) {
    final ExpandableTheme? result =
        context.dependOnInheritedWidgetOfExactType<ExpandableTheme>();

    final ExpandableThemeData expandableThemeData =
        ExpandableThemeData.normal(context);

    final ExpandableThemeData themeData = result?.data ?? expandableThemeData;

    return themeData;
  }

  @override
  bool updateShouldNotify(ExpandableTheme oldWidget) => data != oldWidget.data;
}
