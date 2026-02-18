import 'package:expandable_datatable/src/model/expandable_column.dart';
import 'package:expandable_datatable/src/model/expandable_row.dart';
import 'package:expandable_datatable/src/model/sortable_row.dart';
import 'package:expandable_datatable/src/utility/sort_information.dart';
import 'package:expandable_datatable/src/utility/sort_operations.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a 2-D [SortableRow] list from a flat list (simulates one page).
List<List<SortableRow>> _wrap(List<SortableRow> rows) => [rows];

/// Shorthand row builder.
SortableRow _row(int index, Map<String, dynamic> cells) {
  return SortableRow(
    index,
    row: ExpandableRow(
      cells: cells.entries
          .map((e) => ExpandableCell(columnTitle: e.key, value: e.value))
          .toList(),
    ),
  );
}

void main() {
  late SortOperations ops;

  setUp(() => ops = SortOperations());

  // -------------------------------------------------------------------------
  // String sorting
  // -------------------------------------------------------------------------

  group('string sort', () {
    final col = ExpandableColumn<String>(columnTitle: 'name', columnFlex: 1);

    final rows = _wrap([
      _row(0, {'name': 'Charlie'}),
      _row(1, {'name': 'alice'}),
      _row(2, {'name': 'Bob'}),
    ]);

    test('ASC is case-insensitive alphabetical', () {
      ops.changeSortDirection(col); // NORMAL → ASC

      final result = ops.sortAllRows(col, rows);
      final names = result.map((r) => r.row.cells.first.value).toList();

      expect(names, ['alice', 'Bob', 'Charlie']);
    });

    test('DESC is reverse case-insensitive alphabetical', () {
      ops.changeSortDirection(col); // ASC
      ops.changeSortDirection(col); // DESC

      final result = ops.sortAllRows(col, rows);
      final names = result.map((r) => r.row.cells.first.value).toList();

      expect(names, ['Charlie', 'Bob', 'alice']);
    });

    test('NORMAL (third tap) restores original insertion order via index', () {
      ops.changeSortDirection(col); // ASC
      ops.changeSortDirection(col); // DESC
      ops.changeSortDirection(col); // NORMAL

      final result = ops.sortAllRows(col, rows);
      final indices = result.map((r) => r.index).toList();

      expect(indices, [0, 1, 2]);
    });
  });

  // -------------------------------------------------------------------------
  // Numeric sorting
  // -------------------------------------------------------------------------

  group('numeric sort (int)', () {
    final col = ExpandableColumn<int>(columnTitle: 'score', columnFlex: 1);

    final rows = _wrap([
      _row(0, {'score': 30}),
      _row(1, {'score': -5}),
      _row(2, {'score': 10}),
    ]);

    test('ASC orders negatives before positives', () {
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, rows);
      final scores = result.map((r) => r.row.cells.first.value).toList();

      expect(scores, [-5, 10, 30]);
    });

    test('DESC is reverse numeric order', () {
      ops.changeSortDirection(col);
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, rows);
      final scores = result.map((r) => r.row.cells.first.value).toList();

      expect(scores, [30, 10, -5]);
    });
  });

  group('numeric sort (double)', () {
    final col = ExpandableColumn<double>(columnTitle: 'ratio', columnFlex: 1);

    final rows = _wrap([
      _row(0, {'ratio': 1.5}),
      _row(1, {'ratio': 0.2}),
      _row(2, {'ratio': 3.0}),
    ]);

    test('ASC sorts doubles correctly', () {
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, rows);
      expect(
          result.map((r) => r.row.cells.first.value).toList(), [0.2, 1.5, 3.0]);
    });
  });

  // -------------------------------------------------------------------------
  // Bool sorting
  // -------------------------------------------------------------------------

  group('bool sort', () {
    final col = ExpandableColumn<bool>(columnTitle: 'active', columnFlex: 1);

    final rows = _wrap([
      _row(0, {'active': true}),
      _row(1, {'active': false}),
      _row(2, {'active': true}),
    ]);

    test('ASC places false before true (string comparison: "false" < "true")',
        () {
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, rows);
      expect(result.first.row.cells.first.value, false);
    });

    test('DESC reverses bool order', () {
      ops.changeSortDirection(col);
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, rows);
      expect(result.first.row.cells.first.value, true);
    });
  });

  // -------------------------------------------------------------------------
  // Multi-page flattening
  // -------------------------------------------------------------------------

  group('sortAllRows flattens across pages before sorting', () {
    final col = ExpandableColumn<int>(columnTitle: 'n', columnFlex: 1);

    // Simulate two pages of data.
    final twoPages = [
      [
        _row(0, {'n': 5}),
        _row(1, {'n': 3})
      ],
      [
        _row(2, {'n': 8}),
        _row(3, {'n': 1})
      ],
    ];

    test('ASC sorts across all pages', () {
      ops.changeSortDirection(col);

      final result = ops.sortAllRows(col, twoPages);
      expect(result.map((r) => r.row.cells.first.value).toList(), [1, 3, 5, 8]);
    });

    test('NORMAL unsort preserves original insertion indices across pages', () {
      ops.changeSortDirection(col); // ASC
      ops.changeSortDirection(col); // DESC
      ops.changeSortDirection(col); // NORMAL

      final result = ops.sortAllRows(col, twoPages);
      expect(result.map((r) => r.index).toList(), [0, 1, 2, 3]);
    });
  });

  // -------------------------------------------------------------------------
  // Column-switch during active sort
  // -------------------------------------------------------------------------

  group('switching sort column', () {
    final colName =
        ExpandableColumn<String>(columnTitle: 'name', columnFlex: 1);
    final colScore = ExpandableColumn<int>(columnTitle: 'score', columnFlex: 1);

    final rows = _wrap([
      _row(0, {'name': 'Zara', 'score': 10}),
      _row(1, {'name': 'Anna', 'score': 50}),
      _row(2, {'name': 'Mike', 'score': 20}),
    ]);

    test('switching to a new column sorts by the new column ascending', () {
      ops.changeSortDirection(colName); // colName ASC
      ops.changeSortDirection(colScore); // switch → colScore ASC

      expect(ops.sortInformation.sortOption, SortOption.ASC);
      expect(ops.sortInformation.sortedColumn, same(colScore));

      final result = ops.sortAllRows(colScore, rows);
      expect(result.map((r) => r.row.cells[1].value).toList(), [10, 20, 50]);
    });
  });
}
