import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'C$i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) => ExpandableCell<String>(columnTitle: 'C$c', value: 'r${r}c$c'),
        ),
      ),
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ExpandableColumn.cellBuilder', () {
    testWidgets('custom cellBuilder widget is rendered instead of default Text',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'C0',
          columnFlex: 1,
          cellBuilder: (context, value) =>
              Text('CUSTOM:$value', key: const Key('custom_cell')),
        ),
        ExpandableColumn<String>(columnTitle: 'C1', columnFlex: 1),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'C0', value: 'hello'),
            ExpandableCell<String>(columnTitle: 'C1', value: 'world'),
          ],
        ),
      ];

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 2,
        )),
      );

      // Custom builder output is present for C0
      expect(find.text('CUSTOM:hello'), findsOneWidget);
      // C1 uses default text rendering
      expect(find.text('world'), findsOneWidget);
      // Default plain value for C0 must not appear
      expect(find.text('hello'), findsNothing);
    });

    testWidgets(
        'cellBuilder in expansion column renders custom widget in expand panel',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(columnTitle: 'C0', columnFlex: 1),
        ExpandableColumn<String>(
          columnTitle: 'C1',
          columnFlex: 1,
          cellBuilder: (context, value) =>
              Text('EXP_CUSTOM:$value', key: const Key('exp_custom')),
        ),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'C0', value: 'visible'),
            ExpandableCell<String>(columnTitle: 'C1', value: 'hidden'),
          ],
        ),
      ];

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 1, // C1 goes to expansion
        )),
      );

      // Expand the row
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('EXP_CUSTOM:hidden'), findsOneWidget);
      // Default plain text for C1 must not appear
      expect(find.text('hidden'), findsNothing);
    });

    testWidgets('column without cellBuilder still uses default rendering',
        (tester) async {
      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(1, 2),
          visibleColumnCount: 2,
        )),
      );

      expect(find.text('r0c0'), findsOneWidget);
      expect(find.text('r0c1'), findsOneWidget);
    });
  });
}
