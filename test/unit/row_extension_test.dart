import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:expandable_datatable/src/extension/row_extension.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Regression tests for RowExtension.searchTitleValue.
//
// Bug: searchTitleValue uses `firstWhere` with no `orElse`, so looking up a
// column title that isn't present on the row throws a StateError instead of
// returning null. This matters because a transient header/row mismatch
// during an external data update can crash the sort path, which calls
// searchTitleValue directly.
// ---------------------------------------------------------------------------

void main() {
  group('RowExtension.searchTitleValue', () {
    test('returns the value for an existing column', () {
      final row = ExpandableRow(cells: [
        ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
      ]);

      expect(row.searchTitleValue('Name'), 'Alice');
    });

    test('returns null for a missing column instead of throwing', () {
      final row = ExpandableRow(cells: [
        ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
      ]);

      expect(row.searchTitleValue('Missing'), isNull);
    });
  });
}
