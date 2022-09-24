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

  CellItem({
    required this.columnName,
    this.value,
    this.flex,
  });
}
