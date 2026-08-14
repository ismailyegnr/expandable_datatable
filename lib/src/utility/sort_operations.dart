import 'package:flutter/painting.dart';

import '../extension/row_extension.dart';
import '../extension/sort_extension.dart';
import '../model/expandable_column.dart';
import '../model/sortable_row.dart';
import 'sort_information.dart';

class SortOperations {
  late SortInformation sortInformation;

  SortOperations() {
    sortInformation = SortInformation();
  }

  void changeSortDirection(ExpandableColumn column) {
    sortInformation.nextSort(column);
  }

  List<SortableRow> sortAllRows(
    ExpandableColumn column,
    List<List<SortableRow>> twoDimensionList,
  ) {
    List<SortableRow> tempSortArray = createTempArray(twoDimensionList);

    if (sortInformation.sortOption == SortOption.NORMAL) {
      tempSortArray.unsort;

      return tempSortArray;
    }

    sortTempArray(column, tempSortArray);

    if (sortInformation.sortOption == SortOption.DESC) {
      tempSortArray = tempSortArray.reversed.toList();
    }

    return tempSortArray;
  }

  void sortTempArray(
    ExpandableColumn<dynamic> column,
    List<SortableRow> tempSortArray,
  ) {
    if (column.cellType != null) {
      tempSortArray.sort((a, b) {
        final aRaw = a.row.searchTitleValue(column.columnTitle);
        final bRaw = b.row.searchTitleValue(column.columnTitle);
        return column.cellType!.compare(aRaw, bRaw);
      });
      return;
    }

    switch (column.type) {
      case String:
        tempSortArray.sortStringAscending(column.columnTitle);
        break;
      case bool:
        tempSortArray.sortBoolAscending(column.columnTitle);
        break;
      case ImageProvider:
        // No scalar value to sort by — leave order unchanged.
        break;
      default:
        tempSortArray.sortNumAscending(column.columnTitle);
    }
  }

  List<SortableRow> createTempArray(List<List<SortableRow>> twoDimensionList) {
    List<SortableRow> tempSortArray = [];
    for (int pageX = 0; pageX < twoDimensionList.length; pageX++) {
      for (int rowY = 0; rowY < twoDimensionList[pageX].length; rowY++) {
        tempSortArray.add(twoDimensionList[pageX][rowY]);
      }
    }

    return tempSortArray;
  }
}
