import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'Col $i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) =>
              ExpandableCell<String>(columnTitle: 'Col $c', value: 'r${r}c$c'),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('assert guards', () {
    test('assert fires when visibleColumnCount is 0', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: _rows(1, 3),
          visibleColumnCount: 0,
          pageSize: 10,
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when isEditable=true but onRowChanged is null', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: _rows(1, 3),
          visibleColumnCount: 3,
          pageSize: 10,
          isEditable: true,
          // onRowChanged intentionally omitted
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when row cell count differs from header count', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: [
            ExpandableRow(
              cells: [
                ExpandableCell<String>(columnTitle: 'Col 0', value: 'x'),
                // only 1 cell but headers has 3
              ],
            )
          ],
          visibleColumnCount: 3,
          pageSize: 10,
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when pageSize is 0', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: _rows(1, 3),
          visibleColumnCount: 3,
          pageSize: 0,
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when visibleColumnCount is negative', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: _rows(1, 3),
          visibleColumnCount: -1,
          pageSize: 10,
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when pageSize is negative', () {
      expect(
        () => ExpandableDataTable(
          headers: _headers(3),
          rows: _rows(1, 3),
          visibleColumnCount: 3,
          pageSize: -5,
        ),
        throwsAssertionError,
      );
    });
  });
}
