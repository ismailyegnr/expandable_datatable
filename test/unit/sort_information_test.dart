import 'package:expandable_datatable/src/model/expandable_column.dart';
import 'package:expandable_datatable/src/utility/sort_information.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SortInformation sortInfo;
  late ExpandableColumn<String> colA;
  late ExpandableColumn<String> colB;

  setUp(() {
    sortInfo = SortInformation();
    colA = ExpandableColumn<String>(columnTitle: 'A', columnFlex: 1);
    colB = ExpandableColumn<String>(columnTitle: 'B', columnFlex: 1);
  });

  group('initial state', () {
    test('starts as NORMAL with no sorted column', () {
      expect(sortInfo.sortOption, SortOption.NORMAL);
      expect(sortInfo.sortedColumn, isNull);
    });
  });

  group('single-column cycle: NORMAL → ASC → DESC → NORMAL', () {
    test('first tap on a column moves to ASC', () {
      sortInfo.nextSort(colA);

      expect(sortInfo.sortOption, SortOption.ASC);
      expect(sortInfo.sortedColumn, same(colA));
    });

    test('second tap on the same column moves to DESC', () {
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);

      expect(sortInfo.sortOption, SortOption.DESC);
      expect(sortInfo.sortedColumn, same(colA));
    });

    test('third tap on the same column resets to NORMAL', () {
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);

      expect(sortInfo.sortOption, SortOption.NORMAL);
      expect(sortInfo.sortedColumn, isNull);
    });

    test('a fourth tap restarts the cycle at ASC', () {
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);
      sortInfo.nextSort(colA);

      expect(sortInfo.sortOption, SortOption.ASC);
      expect(sortInfo.sortedColumn, same(colA));
    });
  });

  group('column switch resets direction to ASC', () {
    test('switching from ASC on colA to colB starts at ASC on colB', () {
      sortInfo.nextSort(colA); // colA ASC
      sortInfo.nextSort(colB); // switch to colB

      expect(sortInfo.sortOption, SortOption.ASC);
      expect(sortInfo.sortedColumn, same(colB));
    });

    test('switching from DESC on colA to colB starts at ASC on colB', () {
      sortInfo.nextSort(colA); // ASC
      sortInfo.nextSort(colA); // DESC
      sortInfo.nextSort(colB); // switch

      expect(sortInfo.sortOption, SortOption.ASC);
      expect(sortInfo.sortedColumn, same(colB));
    });

    test('switching back to colA after colB preserves independent cycle', () {
      sortInfo.nextSort(colA); // colA ASC
      sortInfo.nextSort(colB); // colB ASC
      sortInfo.nextSort(
          colA); // colA ASC (fresh start, not continuing from previous)

      expect(sortInfo.sortOption, SortOption.ASC);
      expect(sortInfo.sortedColumn, same(colA));
    });
  });
}
