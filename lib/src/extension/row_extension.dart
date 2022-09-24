import '../model/expandable_row.dart';

extension RowExtension on ExpandableRow {
  dynamic searchTitleValue(String columnTitle) {
    return cells
        .firstWhere((element) => element.columnTitle == columnTitle)
        .value;
  }
}
