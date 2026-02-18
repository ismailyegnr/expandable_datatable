import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'H$i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount, {String prefix = 'v'}) =>
    List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) => ExpandableCell<String>(
              columnTitle: 'H$c', value: '$prefix${r}c$c'),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('rows prop update', () {
    testWidgets('replacing rows rebuilds table with new data', (tester) async {
      var rowData = _rows(2, 3, prefix: 'OLD');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() => rowData = _rows(2, 3, prefix: 'NEW'));
                      },
                      child: const Text('SWAP'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: rowData,
                        visibleColumnCount: 3,
                        pageSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Old data visible
      expect(find.text('OLD0c0'), findsOneWidget);

      // Swap rows
      await tester.tap(find.text('SWAP'));
      await tester.pumpAndSettle();

      // New data visible, old data gone
      expect(find.text('NEW0c0'), findsOneWidget);
      expect(find.text('OLD0c0'), findsNothing);
    });

    for (final multi in [true, false]) {
      testWidgets(
          'updating rows collapses expanded rows (multipleExpansion:$multi)',
          (tester) async {
        var rowData = _rows(2, 3);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => rowData = _rows(2, 3, prefix: 'NEW'));
                        },
                        child: const Text('SWAP'),
                      ),
                      Expanded(
                        child: ExpandableDataTable(
                          headers: _headers(3),
                          rows: rowData,
                          visibleColumnCount: 1,
                          pageSize: 10,
                          multipleExpansion: multi,
                          renderExpansionContent: (row) =>
                              Text('EXPANDED:${row.cells[0].value}'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Expand first row
        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('EXPANDED:'), findsOneWidget);

        // Swap data → didUpdateWidget → _shrinkAllRows → epoch increments → tiles recreated
        await tester.tap(find.text('SWAP'));
        await tester.pumpAndSettle();

        expect(find.textContaining('EXPANDED:'), findsNothing);
      });
    }
  });

  group('pageSize prop update', () {
    testWidgets(
        'reducing pageSize recalculates page count: ToggleButtons gains children',
        (tester) async {
      var pageSize = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => pageSize = 1),
                      child: const Text('REDUCE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(3, 3),
                        visibleColumnCount: 3,
                        pageSize: pageSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // With pageSize=10 and 3 rows → 1 page → ToggleButtons has empty children
      ToggleButtons toggle =
          tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(toggle.children, isEmpty);

      // Reduce to pageSize=1 → 3 pages → pagination has buttons
      await tester.tap(find.text('REDUCE'));
      await tester.pumpAndSettle();

      toggle = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(toggle.children, isNotEmpty);
    });
  });

  group('isEditable prop update', () {
    testWidgets('toggling isEditable shows and hides edit icons',
        (tester) async {
      var editable = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => editable = !editable),
                      child: const Text('TOGGLE'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
                        visibleColumnCount: 3,
                        pageSize: 10,
                        isEditable: editable,
                        onRowChanged: (_, __) {},
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially not editable — no edit icons
      expect(find.byIcon(Icons.edit), findsNothing);

      // Toggle on
      await tester.tap(find.text('TOGGLE'));
      await tester.pumpAndSettle();

      // One edit icon per visible row (2 rows)
      expect(find.byIcon(Icons.edit), findsNWidgets(2));

      // Toggle off again
      await tester.tap(find.text('TOGGLE'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
    });
  });

  group('headers prop update', () {
    testWidgets('updating headers replaces visible column titles',
        (tester) async {
      var headers = [
        ExpandableColumn<String>(columnTitle: 'OldName', columnFlex: 1)
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => headers = [
                            ExpandableColumn<String>(
                                columnTitle: 'NewName', columnFlex: 1)
                          ]),
                      child: const Text('SWAP'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: headers,
                        rows: [
                          ExpandableRow(cells: [
                            ExpandableCell<String>(
                                columnTitle: 'OldName', value: 'x')
                          ])
                        ],
                        visibleColumnCount: 1,
                        pageSize: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('OldName'), findsOneWidget);

      await tester.tap(find.text('SWAP'));
      await tester.pumpAndSettle();

      expect(find.text('NewName'), findsOneWidget);
      expect(find.text('OldName'), findsNothing);
    });
  });
}
