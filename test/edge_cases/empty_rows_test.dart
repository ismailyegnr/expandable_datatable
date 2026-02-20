import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final headers = [
    ExpandableColumn<String>(columnTitle: 'Col 0', columnFlex: 1),
    ExpandableColumn<String>(columnTitle: 'Col 1', columnFlex: 1),
  ];

  group('empty rows list', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: const [],
              visibleColumnCount: 2,
              pageSize: 10,
            ),
          ),
        ),
      );

      // Header column titles still visible
      expect(find.text('Col 0'), findsOneWidget);
      expect(find.text('Col 1'), findsOneWidget);
    });

    testWidgets('no row content is rendered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: const [],
              visibleColumnCount: 2,
              pageSize: 10,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('no pagination buttons rendered for empty rows',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: const [],
              visibleColumnCount: 2,
              pageSize: 10,
            ),
          ),
        ),
      );

      expect(find.byType(ToggleButtons), findsNothing);
    });

    testWidgets('sorting an empty table does not crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: const [],
              visibleColumnCount: 2,
              pageSize: 10,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Col 0').first);
      await tester.pumpAndSettle();

      // No crash and header sort icon appears
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });
  });

  group('single-page boundary (rows == pageSize)', () {
    testWidgets('no pagination buttons when row count equals pageSize',
        (tester) async {
      final rows = List.generate(
        5,
        (i) => ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'Col 0', value: 'r$i'),
            ExpandableCell<String>(columnTitle: 'Col 1', value: 'v$i'),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 2,
              pageSize: 5, // exactly one page → toggle buttons list is empty
            ),
          ),
        ),
      );

      expect(find.byType(ToggleButtons), findsNothing);
    });

    testWidgets('pagination appears when rows exceed pageSize by 1',
        (tester) async {
      final rows = List.generate(
        6,
        (i) => ExpandableRow(
          cells: [
            ExpandableCell<String>(columnTitle: 'Col 0', value: 'r$i'),
            ExpandableCell<String>(columnTitle: 'Col 1', value: 'v$i'),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: rows,
              visibleColumnCount: 2,
              pageSize: 5, // 2 pages
            ),
          ),
        ),
      );

      expect(find.byType(ToggleButtons), findsOneWidget);
    });
  });

  group('null cell values', () {
    testWidgets('null values render as empty string by default',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: headers,
              rows: [
                ExpandableRow(
                  cells: [
                    ExpandableCell<String>(columnTitle: 'Col 0', value: null),
                    ExpandableCell<String>(columnTitle: 'Col 1', value: null),
                  ],
                ),
              ],
              visibleColumnCount: 1,
              pageSize: 10,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Default placeholder is '' — the literal string "null" must never appear
      expect(find.text('null'), findsNothing);
    });
  });
}
