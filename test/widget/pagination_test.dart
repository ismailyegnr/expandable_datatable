import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:expandable_datatable/src/widget/pagination_widget.dart';
import 'package:flutter/material.dart';
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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('pagination — page count calculation', () {
    testWidgets('two pages: ToggleButtons appear when rows exceed pageSize',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(6, 2),
          visibleColumnCount: 2,
          pageSize: 5,
        ),
      ));

      expect(find.byType(ToggleButtons), findsOneWidget);
    });

    testWidgets('correct row count shown per page', (tester) async {
      // 5 rows, pageSize=3 → page 0 has 3 rows, page 1 has 2 rows
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      // Page 0: rows r0c0, r1c0, r2c0
      expect(find.text('r0c0'), findsOneWidget);
      expect(find.text('r1c0'), findsOneWidget);
      expect(find.text('r2c0'), findsOneWidget);
      // Row 3 belongs to page 1 and must not be visible
      expect(find.text('r3c0'), findsNothing);
    });

    testWidgets('next page shows correct rows', (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // Page 1 has rows 3 and 4
      expect(find.text('r3c0'), findsOneWidget);
      expect(find.text('r4c0'), findsOneWidget);
      expect(find.text('r0c0'), findsNothing);
    });

    testWidgets('pageSize 1 creates one page per row', (tester) async {
      // 3 rows, pageSize=1 → 3 pages
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(3, 2),
          visibleColumnCount: 2,
          pageSize: 1,
        ),
      ));

      final tb = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
      expect(tb.children.length, 5); // 3 page buttons + prev + next
    });

    testWidgets('last page shows only the remaining rows, not a full page',
        (tester) async {
      // 5 rows, pageSize=3 → page 0: r0–r2, page 1: r3–r4 (2 rows, not 3)
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      expect(find.text('r3c0'), findsOneWidget);
      expect(find.text('r4c0'), findsOneWidget);
      // r2c0 was on page 0 and must no longer be visible
      expect(find.text('r2c0'), findsNothing);
    });
  });

  group('pagination — single-page boundary', () {
    testWidgets('no pagination buttons when row count equals pageSize',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(5, 2),
          visibleColumnCount: 2,
          pageSize: 5, // exactly one page → toggle buttons list is empty
        ),
      ));

      expect(find.byType(ToggleButtons), findsNothing);
    });

    testWidgets('pagination appears when rows exceed pageSize by 1',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(6, 2),
          visibleColumnCount: 2,
          pageSize: 5, // 2 pages
        ),
      ));

      expect(find.byType(ToggleButtons), findsOneWidget);
    });
  });

  group('pagination — boundary navigation', () {
    testWidgets('previous button on first page does not go below page 0',
        (tester) async {
      int? lastPage;

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(4, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => lastPage = p,
        ),
      ));

      // Tap prev on page 0
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left).first);
      await tester.pumpAndSettle();

      // onPageChanged must not have fired (no navigation happened)
      expect(lastPage, isNull);
    });

    testWidgets('next button on last page does not advance further',
        (tester) async {
      final pages = <int>[];

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(4, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => pages.add(p),
        ),
      ));

      // Advance to last page (page index 1)
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // Try to go further
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // onPageChanged fired exactly once (page 1), not twice
      expect(pages, [1]);
    });

    testWidgets('onPageChanged fires with correct index on each navigation',
        (tester) async {
      final pages = <int>[];

      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(6, 2),
          visibleColumnCount: 2,
          pageSize: 2,
          onPageChanged: (p) => pages.add(p),
        ),
      ));

      // Forward: page 0 → 1 → 2
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      expect(pages, [1, 2]);
    });

    testWidgets('back-navigation from page 2 to page 1 restores correct rows',
        (tester) async {
      // 9 rows, pageSize=3 → 3 pages
      // page 0: r0–r2, page 1: r3–r5, page 2: r6–r8
      await tester.pumpWidget(_wrap(
        ExpandableDataTable(
          headers: _headers(2),
          rows: _rows(9, 2),
          visibleColumnCount: 2,
          pageSize: 3,
        ),
      ));

      // Advance to page 2
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
      await tester.pumpAndSettle();

      // Go back to page 1
      await tester.tap(find.byIcon(Icons.keyboard_arrow_left).first);
      await tester.pumpAndSettle();

      expect(find.text('r3c0'), findsOneWidget);
      expect(find.text('r4c0'), findsOneWidget);
      expect(find.text('r5c0'), findsOneWidget);
      // Page 0 and page 2 rows must not be visible
      expect(find.text('r0c0'), findsNothing);
      expect(find.text('r6c0'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Dynamic-window pagination (totalPageCount > maxVisiblePage)
  //
  // Configuration for all tests below:
  //   totalPageCount = 10, maxVisiblePage = 4  →  midPointMargin = 2
  //
  // Button layout: [prev(0), label(1), label(2), label(3), label(4), next(5)]
  //   → 6 buttons total (maxVisiblePage + 2)
  // ---------------------------------------------------------------------------
  group('pagination — dynamic window (totalPageCount > maxVisiblePage)', () {
    // Stateless helper: builds a PaginationWidget at a fixed currentPage.
    Widget staticPage(int currentPage, {int total = 10, int maxVisible = 4}) =>
        MaterialApp(
          home: Scaffold(
            body: PaginationWidget(
              currentPage: currentPage,
              totalPageCount: total,
              onChanged: (_) {},
              maxVisiblePage: maxVisible,
            ),
          ),
        );

    // Stateful helper: holds page state so taps and external jumps both work.
    Widget drivablePage({
      required int Function() getPage,
      required void Function(StateSetter setter, int newPage) onChanged,
      int total = 10,
      int maxVisible = 4,
    }) =>
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) => PaginationWidget(
                currentPage: getPage(),
                totalPageCount: total,
                onChanged: (p) => onChanged(setState, p),
                maxVisiblePage: maxVisible,
              ),
            ),
          ),
        );

    testWidgets(
      'button count is fixed at maxVisiblePage + 2',
      (tester) async {
        await tester.pumpWidget(staticPage(0));

        final tb = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        // 4 page-number buttons + prev + next
        expect(tb.children.length, 6);
      },
    );

    testWidgets(
      'initial window is left-clamped — shows labels 1..maxVisiblePage',
      (tester) async {
        // Page 0: _changeMidPoint(0) → 0 < midPointMargin(2) → _midPoint=2
        // Labels: 2+0-2+1=1, …, 2+3-2+1=4  →  1 2 3 4
        await tester.pumpWidget(staticPage(0));

        for (final label in ['1', '2', '3', '4']) {
          expect(find.text(label), findsOneWidget, reason: 'label $label');
        }
        expect(find.text('5'), findsNothing);
      },
    );

    testWidgets(
      'window slides into the middle zone when page crosses midPointMargin',
      (tester) async {
        // After 3 taps right: page 0→1→2→3
        // _changeMidPoint(3): 3 not <2, not >8  →  _midPoint=3
        // Labels: 3+0-2+1=2, …, 3+3-2+1=5  →  2 3 4 5
        int page = 0;
        await tester.pumpWidget(drivablePage(
          getPage: () => page,
          onChanged: (setState, p) => setState(() => page = p),
        ));

        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byIcon(Icons.keyboard_arrow_right).first);
          await tester.pumpAndSettle();
        }

        expect(find.text('1'), findsNothing);
        for (final label in ['2', '3', '4', '5']) {
          expect(find.text(label), findsOneWidget, reason: 'label $label');
        }
        expect(find.text('6'), findsNothing);
      },
    );

    testWidgets(
      'selected toggle button matches the current page in the dynamic window',
      (tester) async {
        // At page 3, _midPoint=3, labels 2 3 4 5.
        // toggleIndex = (midPointMargin+1) + (page - _midPoint) = 3 + 0 = 3
        // → isSelected[3] = true  →  children[3] = Text("4")
        int page = 0;
        late StateSetter jump;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                jump = setState;
                return PaginationWidget(
                  currentPage: page,
                  totalPageCount: 10,
                  onChanged: (p) => setState(() => page = p),
                  maxVisiblePage: 4,
                );
              },
            ),
          ),
        ));

        jump(() => page = 3);
        await tester.pumpAndSettle();

        final tb = tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        expect(tb.isSelected[3], isTrue,
            reason: 'page 3 maps to toggle index 3 (label "4")');
        expect(tb.isSelected[2], isFalse);
        expect(tb.isSelected[4], isFalse);
      },
    );

    testWidgets(
      'window is right-clamped on last pages — shows last maxVisiblePage labels',
      (tester) async {
        // Page 9: _changeMidPoint(9) → 9 > 10-4+2=8  →  _midPoint=8
        // Labels: 8+0-2+1=7, …, 8+3-2+1=10  →  7 8 9 10
        int page = 0;
        late StateSetter jump;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                jump = setState;
                return PaginationWidget(
                  currentPage: page,
                  totalPageCount: 10,
                  onChanged: (p) => setState(() => page = p),
                  maxVisiblePage: 4,
                );
              },
            ),
          ),
        ));

        jump(() => page = 9);
        await tester.pumpAndSettle();

        expect(find.text('6'), findsNothing);
        for (final label in ['7', '8', '9', '10']) {
          expect(find.text(label), findsOneWidget, reason: 'label $label');
        }
      },
    );

    testWidgets(
      'page 8 and page 9 share same window but different selected buttons',
      (tester) async {
        // Both pages clamp _midPoint to 8, showing 7 8 9 10.
        // Page 8: toggleIndex = 3+0 = 3  →  label "9" selected
        // Page 9: toggleIndex = 3+1 = 4  →  label "10" selected
        int page = 0;
        late StateSetter jump;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                jump = setState;
                return PaginationWidget(
                  currentPage: page,
                  totalPageCount: 10,
                  onChanged: (p) => setState(() => page = p),
                  maxVisiblePage: 4,
                );
              },
            ),
          ),
        ));

        jump(() => page = 8);
        await tester.pumpAndSettle();

        final tbPage8 =
            tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        // isSelected[3] == true  →  label "9"
        expect(tbPage8.isSelected[3], isTrue);
        expect(tbPage8.isSelected[4], isFalse);

        jump(() => page = 9);
        await tester.pumpAndSettle();

        final tbPage9 =
            tester.widget<ToggleButtons>(find.byType(ToggleButtons));
        // isSelected[4] == true  →  label "10"
        expect(tbPage9.isSelected[4], isTrue);
        expect(tbPage9.isSelected[3], isFalse);
      },
    );

    testWidgets(
      'tapping a page label navigates to the correct 0-based page index',
      (tester) async {
        // Initial: page=0, _midPoint=2, labels 1 2 3 4.
        // Tap "3"  (children index 3):
        //   newPage = _midPoint + (3 - (midPointMargin+1)) = 2 + 0 = 2
        final logged = <int>[];
        int page = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) => PaginationWidget(
                currentPage: page,
                totalPageCount: 10,
                onChanged: (p) {
                  setState(() => page = p);
                  logged.add(p);
                },
                maxVisiblePage: 4,
              ),
            ),
          ),
        ));

        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        expect(logged, [2]);
      },
    );

    testWidgets(
      'window reverts to left-clamp when navigating back to an early page',
      (tester) async {
        // Navigate deep (page 8), then jump back to page 1.
        // page 1 < midPointMargin(2)  →  _midPoint=2  →  labels 1 2 3 4
        int page = 0;
        late StateSetter jump;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                jump = setState;
                return PaginationWidget(
                  currentPage: page,
                  totalPageCount: 10,
                  onChanged: (p) => setState(() => page = p),
                  maxVisiblePage: 4,
                );
              },
            ),
          ),
        ));

        jump(() => page = 8);
        await tester.pumpAndSettle();
        // Sanity: deep window shows 7..10
        expect(find.text('7'), findsOneWidget);

        jump(() => page = 1);
        await tester.pumpAndSettle();

        for (final label in ['1', '2', '3', '4']) {
          expect(find.text(label), findsOneWidget, reason: 'label $label');
        }
        expect(find.text('5'), findsNothing);
      },
    );
  });
}
