// ignore_for_file: constant_identifier_names

import '../../expandable_datatable.dart';

enum SortType { ASC, DESC, ORIGINAL }

class SortUtil {
  SortType _sortType = SortType.ORIGINAL;
  String _sortedAccessor = "";

  late final List<ExpandableRow> _originalList;
  late List<ExpandableRow> _sortedList;

  SortUtil(List<ExpandableRow> rows) {
    _originalList = rows;
    _sortedList = List.from(_originalList);
  }

  String get sortedAccessor => _sortedAccessor;
  SortType get sortType => _sortType;

  List<ExpandableRow> get rows => _sortedList;

  void sort(ExpandableColumn column) {
    // Update private fields
    if (column.accessor == _sortedAccessor) {
      if (_sortType == SortType.ORIGINAL) {
        _sortType = SortType.ASC;
      } else if (_sortType == SortType.ASC) {
        _sortType = SortType.DESC;
      } else if (_sortType == SortType.DESC) {
        _sortType = SortType.ORIGINAL;
      }
    } else {
      _sortedAccessor = column.accessor;
      _sortType = SortType.ASC;
    }

    // Sort list according to private properties
    if (_sortType == SortType.ORIGINAL) {
      _sortedList = List.from(_originalList);
      return;
    }
    _sortedList.sort(
      (a, b) {
        return a.cells
            .firstWhere((element) => element.accessor == _sortedAccessor)
            .value
            .compareTo(b.cells
                .firstWhere((element) => element.accessor == _sortedAccessor)
                .value);
      },
    );
    if (_sortType == SortType.DESC) {
      _sortedList = _sortedList.reversed.toList();
    }
  }
}
