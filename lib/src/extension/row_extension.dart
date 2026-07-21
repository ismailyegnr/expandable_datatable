import '../model/expandable_row.dart';

extension RowExtension on ExpandableRow {
  dynamic searchTitleValue(String columnTitle) {
    for (final cell in cells) {
      if (cell.columnTitle == columnTitle) {
        return cell.value;
      }
    }
    return null;
  }
}
