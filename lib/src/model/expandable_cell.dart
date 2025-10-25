import 'package:flutter/material.dart';

typedef StringCell = StringExpandableCell;
typedef NumberCell = NumberExpandableCell;
typedef BooleanCell = BooleanExpandableCell;

abstract class ExpandableCell<T> {
  final T value;
  final String accessor;
  final Widget Function() render;

  ExpandableCell({
    required this.value,
    required this.accessor,
    required this.render,
  });
}

class StringExpandableCell extends ExpandableCell<String> {
  final TextStyle? textStyle;

  StringExpandableCell({
    required String value,
    required String accessor,
    Widget Function()? render,
    this.textStyle,
  }) : super(
          value: value,
          accessor: accessor,
          render: render ?? () => Text(value, style: textStyle),
        );
}

class NumberExpandableCell extends ExpandableCell<num> {
  final TextStyle? textStyle;

  NumberExpandableCell({
    required num value,
    required String accessor,
    Widget Function()? render,
    this.textStyle,
  }) : super(
          value: value,
          accessor: accessor,
          render: render ?? () => Text(value.toString(), style: textStyle),
        );
}

class BooleanExpandableCell extends ExpandableCell<bool> {
  final TextStyle? textStyle;
  final Alignment alignment;

  BooleanExpandableCell({
    required bool value,
    required String accessor,
    Widget Function()? render,
    this.textStyle,
    this.alignment = Alignment.centerLeft,
  }) : super(
          value: value,
          accessor: accessor,
          render: render ??
              () => Align(
                    alignment: alignment,
                    child: Icon(
                      value ? Icons.check : Icons.close,
                      color: textStyle?.color,
                    ),
                  ),
        );
}
