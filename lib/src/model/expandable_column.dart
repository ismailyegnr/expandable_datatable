import 'package:flutter/material.dart';

import 'cell_type.dart';

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

  /// Optional per-column cell builder. When provided, this callback is used
  /// to render every cell in this column instead of the built-in type
  /// inference logic.
  ///
  /// ```dart
  /// ExpandableColumn<ImageProvider>(
  ///   columnTitle: 'Avatar',
  ///   columnFlex: 2,
  ///   cellBuilder: (context, value) {
  ///     return ClipRRect(
  ///       borderRadius: BorderRadius.circular(8),
  ///       child: Image(
  ///         image: value as ImageProvider,
  ///         height: 56,
  ///         fit: BoxFit.cover,
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  final Widget Function(BuildContext context, dynamic value)? cellBuilder;

  /// Optional [CellType] adapter that controls rendering, sorting, editing,
  /// and string formatting for this column's data type.
  ///
  /// When omitted, generic-based type inference is used.
  final CellType<T>? cellType;

  Type get type => T;

  ExpandableColumn({
    required this.columnTitle,
    required this.columnFlex,
    this.isEditable = true,
    this.hintText,
    bool? isSortable,
    this.cellBuilder,
    this.cellType,
  }) : isSortable = isSortable ?? (T != ImageProvider && cellType is! ImageCellType);
}
