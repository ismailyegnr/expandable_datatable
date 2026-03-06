import 'dart:typed_data';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(List<String> names) => names
    .map((n) => ExpandableColumn<String>(columnTitle: n, columnFlex: 1))
    .toList();

List<ExpandableRow> _rows(List<List<String>> data, List<String> colNames) =>
    data
        .map((row) => ExpandableRow(
              cells: List.generate(
                row.length,
                (i) => ExpandableCell<String>(
                    columnTitle: colNames[i], value: row[i]),
              ),
            ))
        .toList();

Widget _buildSortTable(List<String> colNames, List<List<String>> data) {
  return MaterialApp(
    home: Scaffold(
      body: ExpandableDataTable(
        headers: _headers(colNames),
        rows: _rows(data, colNames),
        visibleColumnCount: colNames.length,
        pageSize: 20,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const colNames = ['Name', 'Score'];

  final tableData = [
    ['Charlie', '30'],
    ['Alice', '10'],
    ['Bob', '20'],
  ];

  group('header sort icon visibility', () {
    testWidgets('no sort icon shown before any header tap', (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('first tap shows ASC arrow on the tapped column',
        (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('second tap shows DESC arrow on the same column',
        (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
    });

    testWidgets('third tap removes sort arrow entirely (NORMAL)',
        (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets(
        'tapping a different column moves sort icon; previous column loses icon',
        (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      // Sort by Name
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);

      // Switch to Score — Name loses icon, Score gains it
      await tester.tap(find.text('Score').first);
      await tester.pumpAndSettle();

      // Still exactly one ASC icon (on Score now)
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });
  });

  group('sort changes displayed row order', () {
    testWidgets('ASC sort reorders rows alphabetically', (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      // Row texts should now appear in A→B→C order in the widget tree
      final nameFinder = find.text('Alice');
      final bobFinder = find.text('Bob');
      final charlieFinder = find.text('Charlie');

      final aliceY = tester.getTopLeft(nameFinder).dy;
      final bobY = tester.getTopLeft(bobFinder).dy;
      final charlieY = tester.getTopLeft(charlieFinder).dy;

      expect(aliceY, lessThan(bobY));
      expect(bobY, lessThan(charlieY));
    });

    testWidgets('NORMAL (third tap) restores insertion order', (tester) async {
      await tester.pumpWidget(_buildSortTable(colNames, tableData));

      // Three taps: ASC → DESC → NORMAL
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      // Insertion order: Charlie (top), Alice, Bob
      final charlieY = tester.getTopLeft(find.text('Charlie')).dy;
      final aliceY = tester.getTopLeft(find.text('Alice')).dy;
      final bobY = tester.getTopLeft(find.text('Bob')).dy;

      expect(charlieY, lessThan(aliceY));
      expect(aliceY, lessThan(bobY));
    });

    testWidgets('sort resets to page 0', (tester) async {
      // 4 rows with pageSize=2 → 2 pages.
      // Page 1: Zara, Anna  |  Page 2: Mike, Dave
      final moreData = [
        ['Zara', '1'],
        ['Anna', '2'],
        ['Mike', '3'],
        ['Dave', '4'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandableDataTable(
              headers: _headers(colNames),
              rows: _rows(moreData, colNames),
              visibleColumnCount: colNames.length,
              pageSize: 2, // ← must be 2 so rows are split across pages
            ),
          ),
        ),
      );

      // Page 1 shows Zara and Anna; Mike and Dave are on page 2
      expect(find.text('Zara'), findsOneWidget);
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Mike'), findsNothing);
      expect(find.text('Dave'), findsNothing);

      // Navigate to page 2 via ToggleButtons.onPressed
      final toggle = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      toggle.onPressed!(toggle.children.length - 1); // next button
      await tester.pumpAndSettle();

      // Mike and Dave are now visible; Zara and Anna are not
      expect(find.text('Mike'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);
      expect(find.text('Zara'), findsNothing);
      expect(find.text('Anna'), findsNothing);

      // Sort by Name → resets _currentPage to 0
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      // After ASC sort page 1 shows Anna and Dave (first two alphabetically)
      expect(find.text('Anna'), findsOneWidget);
      expect(find.text('Dave'), findsOneWidget);
      expect(find.text('Mike'), findsNothing);
      expect(find.text('Zara'), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // isSortable = false behavior
  // -------------------------------------------------------------------------

  group('isSortable = false behavior', () {
    testWidgets(
        'tapping a column with isSortable:false never shows a sort icon',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'Name',
          columnFlex: 1,
          isSortable: false,
        ),
        ExpandableColumn<String>(columnTitle: 'Score', columnFlex: 1),
      ];

      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Charlie'),
          ExpandableCell<String>(columnTitle: 'Score', value: '30'),
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
          ExpandableCell<String>(columnTitle: 'Score', value: '10'),
        ]),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 2,
            pageSize: 20,
          ),
        ),
      ));

      // Tap the non-sortable column three times — still no sort icon.
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('tapping a non-sortable column does not reorder rows',
        (tester) async {
      final headers = [
        ExpandableColumn<String>(
          columnTitle: 'Name',
          columnFlex: 1,
          isSortable: false,
        ),
      ];

      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Charlie'),
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Bob'),
        ]),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 1,
            pageSize: 20,
          ),
        ),
      ));

      // Insertion order before tap: Charlie, Alice, Bob.
      final charlieBefore = tester.getTopLeft(find.text('Charlie')).dy;
      final aliceBefore = tester.getTopLeft(find.text('Alice')).dy;
      final bobBefore = tester.getTopLeft(find.text('Bob')).dy;

      expect(charlieBefore, lessThan(aliceBefore));
      expect(aliceBefore, lessThan(bobBefore));

      // Tap — order must be unchanged.
      await tester.tap(find.text('Name').first);
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('Charlie')).dy, charlieBefore);
      expect(tester.getTopLeft(find.text('Alice')).dy, aliceBefore);
      expect(tester.getTopLeft(find.text('Bob')).dy, bobBefore);
    });

    testWidgets(
        'ImageProvider column (default isSortable:false) shows no sort icon on tap',
        (tester) async {
      final img = MemoryImage(Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x62,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]));

      final headers = <ExpandableColumn<dynamic>>[
        ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 1),
        ExpandableColumn<ImageProvider>(columnTitle: 'Photo', columnFlex: 1),
      ];

      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
          ExpandableCell<ImageProvider>(columnTitle: 'Photo', value: img),
        ]),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 2,
            pageSize: 20,
          ),
        ),
      ));

      await tester.tap(find.text('Photo').first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets(
        'sortable column still works normally alongside a non-sortable column',
        (tester) async {
      final headers = <ExpandableColumn<dynamic>>[
        ExpandableColumn<String>(
          columnTitle: 'Name',
          columnFlex: 1,
          isSortable: false,
        ),
        ExpandableColumn<String>(columnTitle: 'Score', columnFlex: 1),
      ];

      final rows = [
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Charlie'),
          ExpandableCell<String>(columnTitle: 'Score', value: '30'),
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
          ExpandableCell<String>(columnTitle: 'Score', value: '10'),
        ]),
        ExpandableRow(cells: [
          ExpandableCell<String>(columnTitle: 'Name', value: 'Bob'),
          ExpandableCell<String>(columnTitle: 'Score', value: '20'),
        ]),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExpandableDataTable(
            headers: headers,
            rows: rows,
            visibleColumnCount: 2,
            pageSize: 20,
          ),
        ),
      ));

      // Tap the sortable Score column → ASC arrow should appear.
      await tester.tap(find.text('Score').first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
    });
  });
}
