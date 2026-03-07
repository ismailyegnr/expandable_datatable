import 'package:flutter/painting.dart';

class ExpandableColumn<T> {
  String columnTitle;
  int columnFlex;

  /// Whether this column's field is editable in the default [EditDialog].
  ///
  /// When set to false, the corresponding input field is disabled and the
  /// original cell value is preserved unchanged after saving.
  ///
  /// Defaults to true.
  final bool isEditable;

  /// Optional hint text displayed inside this column's input field in the
  /// default [EditDialog].
  final String? hintText;

  /// Whether tapping this column's header affects the table sort order.
  ///
  /// When set to false, tapping the header is a complete no-op — no sort icon
  /// is shown and the row order is not changed.
  ///
  /// Defaults to false for [ImageProvider] columns and true for all others.
  final bool isSortable;

  Type get type => T;

  ExpandableColumn({
    required this.columnTitle,
    required this.columnFlex,
    this.isEditable = true,
    this.hintText,
    bool? isSortable,
  }) : isSortable = isSortable ?? (T != ImageProvider);
}
