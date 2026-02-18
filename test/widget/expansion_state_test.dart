import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'Col $i', columnFlex: 1),
    );

/// Builds rows. Each row's cell value encodes its position as 'r{row}c{col}'.
List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) => ExpandableCell<String>(
              columnTitle: 'Col $c', value: 'r${r}c${c}'),
        ),
      ),
    );

/// Wraps the table in a properly-bounded host widget.
Widget _host(Widget table) => MaterialApp(
      home: Scaffold(body: table),
    );

/// Returns a table where:
/// - Column 0 is visible
/// - Columns 1..colCount-1 are in the expansion area
/// - Each row's expansion content is identified via a unique Text widget.
Widget _buildTable({
  required int rowCount,
  required int colCount,
  int visibleColumnCount = 1,
  bool multipleExpansion = true,
  int pageSize = 20,
}) {
  final headers = _headers(colCount);
  final rows = _rows(rowCount, colCount);

  return _host(
    ExpandableDataTable(
      headers: headers,
      rows: rows,
      visibleColumnCount: visibleColumnCount,
      pageSize: pageSize,
      multipleExpansion: multipleExpansion,
      renderExpansionContent: (row) {
        // Unique marker text: "EXPANDED:<row-index-value>"
        final rowId = row.cells[0].value;
        return Text('EXPANDED:$rowId');
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('basic expansion & collapse', () {
    testWidgets('row expands on tap and shows expansion content',
        (tester) async {
      await tester.pumpWidget(_buildTable(rowCount: 2, colCount: 3));

      expect(find.textContaining('EXPANDED:'), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('EXPANDED:r0c0'), findsOneWidget);
    });

    testWidgets('expanded row collapses on second tap', (tester) async {
      await tester.pumpWidget(_buildTable(rowCount: 2, colCount: 3));

      // Expand
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      expect(find.text('EXPANDED:r0c0'), findsOneWidget);

      // Collapse — the icon rotates (RotationTransition), tap it again
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('EXPANDED:r0c0'), findsNothing);
    });
  });

  group('multipleExpansion: true (default)', () {
    testWidgets('multiple rows can be expanded simultaneously', (tester) async {
      await tester.pumpWidget(
        _buildTable(rowCount: 3, colCount: 3, multipleExpansion: true),
      );

      final icons = find.byIcon(Icons.expand_more);

      // Expand row 0
      await tester.tap(icons.at(0));
      await tester.pumpAndSettle();

      // Expand row 1
      await tester.tap(icons.at(1));
      await tester.pumpAndSettle();

      // Both expansion contents must be visible at the same time
      expect(find.text('EXPANDED:r0c0'), findsOneWidget);
      expect(find.text('EXPANDED:r1c0'), findsOneWidget);
    });
  });

  group('multipleExpansion: false', () {
    testWidgets('opening row B collapses row A', (tester) async {
      await tester.pumpWidget(
        _buildTable(rowCount: 3, colCount: 3, multipleExpansion: false),
      );

      final icons = find.byIcon(Icons.expand_more);

      // Expand row 0
      await tester.tap(icons.at(0));
      await tester.pumpAndSettle();
      expect(find.text('EXPANDED:r0c0'), findsOneWidget);

      // Expand row 1 — row 0 must close
      await tester.tap(icons.at(1));
      await tester.pumpAndSettle();

      expect(find.text('EXPANDED:r1c0'), findsOneWidget);
      expect(find.text('EXPANDED:r0c0'), findsNothing);
    });

    testWidgets('tapping the already-open row closes it', (tester) async {
      await tester.pumpWidget(
        _buildTable(rowCount: 2, colCount: 3, multipleExpansion: false),
      );

      final icons = find.byIcon(Icons.expand_more);

      // Open row 0
      await tester.tap(icons.at(0));
      await tester.pumpAndSettle();
      expect(find.text('EXPANDED:r0c0'), findsOneWidget);

      // Close row 0 by tapping it again
      await tester.tap(icons.at(0));
      await tester.pumpAndSettle();

      expect(find.text('EXPANDED:r0c0'), findsNothing);
    });
  });

  group('expansion collapses on page change', () {
    for (final multi in [true, false]) {
      testWidgets(
          'expanded row is collapsed after navigating to a new page '
          '(multipleExpansion:$multi)', (tester) async {
        // 3 rows with pageSize=2 → 2 pages
        await tester.pumpWidget(
          _buildTable(
            rowCount: 3,
            colCount: 3,
            visibleColumnCount: 1,
            pageSize: 2,
            multipleExpansion: multi,
          ),
        );

        // Expand first row on page 1
        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();
        expect(find.text('EXPANDED:r0c0'), findsOneWidget);

        // Navigate to page 2
        await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
        await tester.pumpAndSettle();

        // Navigate back to page 1
        await tester.tap(find.byIcon(Icons.keyboard_arrow_left).first);
        await tester.pumpAndSettle();

        // Row must be collapsed in both multipleExpansion modes
        expect(find.text('EXPANDED:r0c0'), findsNothing);
      });
    }
  });

  group('expansion collapses on sort', () {
    for (final multi in [true, false]) {
      testWidgets(
          'sort resets expanded state to collapsed (multipleExpansion:$multi)',
          (tester) async {
        await tester.pumpWidget(
          _host(
            ExpandableDataTable(
              headers: _headers(3),
              rows: _rows(3, 3),
              visibleColumnCount: 1,
              pageSize: 20,
              multipleExpansion: multi,
              renderExpansionContent: (row) =>
                  Text('EXPANDED:${row.cells[0].value}'),
            ),
          ),
        );

        // Expand row 0
        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();
        expect(find.text('EXPANDED:r0c0'), findsOneWidget);

        // Tap the header to trigger a sort
        await tester.tap(find.text('Col 0').first);
        await tester.pumpAndSettle();

        // Row must be collapsed in both multipleExpansion modes
        expect(find.text('EXPANDED:r0c0'), findsNothing);
      });
    }
  });
}
