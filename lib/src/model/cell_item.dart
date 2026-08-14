import 'package:flutter/material.dart';

import 'cell_type.dart';

/// [ExpansionTile] title class that helps to build rows.
///
/// Multiple [CellItem] creates a title of the row.
class CellItem {
  ///  The name of the column where you want to place this cell
  String columnName;

  /// Value of the cell
  dynamic value;

  /// The flexible value you want this cell to contain
  int? flex;

  /// Resolved per-cell rendering callback, copied from the matching
  /// [ExpandableColumn.cellBuilder] by [ExpandableDataTable._createRowCells].
  /// When non-null, this widget is returned directly by the cell rendering
  /// methods, bypassing the built-in type inference.
  final Widget Function(BuildContext context, dynamic value)? cellBuilder;

  /// Resolved [CellType] adapter, copied from the matching
  /// [ExpandableColumn.cellType] by [ExpandableDataTable._createRowCells].
  final CellType? cellType;

  /// Placeholder string to display when [value] is null.
  final String? nullValuePlaceholder;

  CellItem({
    required this.columnName,
    this.value,
    this.flex,
    this.cellBuilder,
    this.cellType,
    this.nullValuePlaceholder,
  });
}

