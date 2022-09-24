// ignore_for_file: constant_identifier_names

import '../model/expandable_column.dart';

enum SortOption { ASC, DESC, NORMAL }

class SortInformation {
  ExpandableColumn? sortedColumn;
  late SortOption sortOption;

  SortInformation() {
    sortedColumn = null;
    sortOption = SortOption.NORMAL;
  }

  void nextSort(ExpandableColumn column) {
    if (sortOption == SortOption.NORMAL) {
      sortOption = SortOption.ASC;
      sortedColumn = column;
    } else if (sortedColumn != column) {
      sortOption = SortOption.ASC;
      sortedColumn = column;
    } else if (sortOption == SortOption.ASC) {
      sortOption = SortOption.DESC;
      sortedColumn = column;
    } else {
      sortOption = SortOption.NORMAL;
      sortedColumn = null;
    }
  }
}
