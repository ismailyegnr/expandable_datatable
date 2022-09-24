import '../model/sortable_row.dart';
import 'row_extension.dart';

extension ListSortExtension on List<SortableRow> {
  void get unsort => sort(
        (a, b) => a.index.compareTo(b.index),
      );

  void sortStringAscending(String columnTitle) {
    sort(
      (a, b) => a.row.searchTitleValue(columnTitle).toLowerCase().compareTo(
            b.row.searchTitleValue(columnTitle).toLowerCase(),
          ),
    );
  }

  void sortBoolAscending(String columnTitle) {
    sort(
      (a, b) => a.row.searchTitleValue(columnTitle).toString().compareTo(
            b.row.searchTitleValue(columnTitle).toString().toLowerCase(),
          ),
    );
  }

  void sortNumAscending(String columnTitle) {
    sort(
      (a, b) => a.row.searchTitleValue(columnTitle).compareTo(
            b.row.searchTitleValue(columnTitle),
          ),
    );
  }
}
