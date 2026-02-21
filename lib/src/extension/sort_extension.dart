import '../model/sortable_row.dart';
import 'row_extension.dart';

extension ListSortExtension on List<SortableRow> {
  void get unsort => sort(
        (a, b) => a.index.compareTo(b.index),
      );

  void sortStringAscending(String columnTitle) {
    sort(
      (a, b) {
        final aVal =
            a.row.searchTitleValue(columnTitle)?.toString().toLowerCase() ?? '';
        final bVal =
            b.row.searchTitleValue(columnTitle)?.toString().toLowerCase() ?? '';
        return aVal.compareTo(bVal);
      },
    );
  }

  void sortBoolAscending(String columnTitle) {
    sort(
      (a, b) {
        final aRaw = a.row.searchTitleValue(columnTitle);
        final bRaw = b.row.searchTitleValue(columnTitle);
        if (aRaw == null && bRaw == null) return 0;
        if (aRaw == null) return -1;
        if (bRaw == null) return 1;
        // false (0) sorts before true (1)
        return (aRaw as bool ? 1 : 0).compareTo(bRaw as bool ? 1 : 0);
      },
    );
  }

  void sortNumAscending(String columnTitle) {
    sort(
      (a, b) {
        final aRaw = a.row.searchTitleValue(columnTitle);
        final bRaw = b.row.searchTitleValue(columnTitle);
        if (aRaw == null && bRaw == null) return 0;
        if (aRaw == null) return -1;
        if (bRaw == null) return 1;
        return (aRaw as num).compareTo(bRaw as num);
      },
    );
  }
}
