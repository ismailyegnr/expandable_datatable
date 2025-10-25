import 'package:expandable_datatable/src/model/expandable_column.dart';
import 'expandable_cell.dart';

/// [ExpansionTile] title class that helps to build rows.
///
/// Multiple [CellItem] creates a row.
class CellItem {
  String? header;
  ExpandableCell cellInfo;
  int flex;

  CellItem({
    this.header,
    required this.cellInfo,
    required this.flex,
  });
}

class CellData {
  ExpandableColumn column;
  ExpandableCell cell;

  CellData({
    required this.column,
    required this.cell,
  });
}
