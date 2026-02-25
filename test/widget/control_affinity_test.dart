import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<ExpandableColumn<String>> _headers(int count) => List.generate(
      count,
      (i) => ExpandableColumn<String>(columnTitle: 'Col$i', columnFlex: 1),
    );

List<ExpandableRow> _rows(int rowCount, int colCount) => List.generate(
      rowCount,
      (r) => ExpandableRow(
        cells: List.generate(
          colCount,
          (c) =>
              ExpandableCell<String>(columnTitle: 'Col$c', value: 'r${r}c$c'),
        ),
      ),
    );

/// Wraps the table in a properly-bounded host widget.
Widget _host(Widget table) => MaterialApp(home: Scaffold(body: table));

/// Builds a standard table with [colCount] columns, [visibleColumnCount]
/// visible columns and optional [affinity] / [isEditable] overrides.
Widget _buildTable({
  int rowCount = 3,
  int colCount = 3,
  int visibleColumnCount = 1,
  ListTileControlAffinity affinity = ListTileControlAffinity.trailing,
  bool isEditable = false,
  ExpandableThemeData? themeData,
}) {
  Widget table = ExpandableDataTable(
    headers: _headers(colCount),
    rows: _rows(rowCount, colCount),
    visibleColumnCount: visibleColumnCount,
    pageSize: 20,
    expansionIconAffinity: affinity,
    isEditable: isEditable,
    onRowChanged: isEditable ? (_, __) {} : null,
  );

  if (themeData != null) {
    table = ExpandableTheme(data: themeData, child: table);
  }

  return _host(table);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('expansion icon placement', () {
    testWidgets(
        'default (trailing): expansion icon is to the right of the title text',
        (tester) async {
      await tester.pumpWidget(_buildTable());

      final double iconX =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(iconX, greaterThan(titleX));
    });

    testWidgets(
        'leading affinity: expansion icon is to the left of the title text',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(affinity: ListTileControlAffinity.leading),
      );

      final double iconX =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(iconX, lessThan(titleX));
    });
  });

  group('header ghost alignment', () {
    testWidgets(
        'trailing affinity: header column left-edge matches row content left-edge',
        (tester) async {
      await tester.pumpWidget(_buildTable());

      final double headerX = tester.getTopLeft(find.text('Col0').first).dx;
      final double rowX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(headerX, moreOrLessEquals(rowX, epsilon: 1.0));
    });

    testWidgets(
        'leading affinity: header column left-edge matches row content left-edge',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(affinity: ListTileControlAffinity.leading),
      );

      final double headerX = tester.getTopLeft(find.text('Col0').first).dx;
      final double rowX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(headerX, moreOrLessEquals(rowX, epsilon: 1.0));
    });
  });

  group('leading icon tap', () {
    testWidgets('tapping the leading icon expands a collapsed row',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(affinity: ListTileControlAffinity.leading),
      );

      expect(find.text('Col1:'), findsNothing);

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('Col1:'), findsOneWidget);
    });

    testWidgets('tapping the leading icon again collapses the row',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(affinity: ListTileControlAffinity.leading),
      );

      // Expand
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      expect(find.text('Col1:'), findsOneWidget);

      // Collapse
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      expect(find.text('Col1:'), findsNothing);
    });
  });

  group('dynamic affinity switch via didUpdateWidget', () {
    testWidgets('switching from trailing to leading moves icon to the left',
        (tester) async {
      var affinity = ListTileControlAffinity.trailing;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(
                          () => affinity = ListTileControlAffinity.leading),
                      child: const Text('SWITCH'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
                        visibleColumnCount: 1,
                        pageSize: 20,
                        expansionIconAffinity: affinity,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Trailing: icon is to the right of the title
      final double iconXBefore =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleXBefore = tester.getTopLeft(find.text('r0c0').first).dx;
      expect(iconXBefore, greaterThan(titleXBefore));

      // Switch to leading
      await tester.tap(find.text('SWITCH'));
      await tester.pumpAndSettle();

      final double iconXAfter =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleXAfter = tester.getTopLeft(find.text('r0c0').first).dx;
      expect(iconXAfter, lessThan(titleXAfter));
    });

    testWidgets('switching from leading to trailing moves icon to the right',
        (tester) async {
      var affinity = ListTileControlAffinity.leading;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => setState(
                          () => affinity = ListTileControlAffinity.trailing),
                      child: const Text('SWITCH'),
                    ),
                    Expanded(
                      child: ExpandableDataTable(
                        headers: _headers(3),
                        rows: _rows(2, 3),
                        visibleColumnCount: 1,
                        pageSize: 20,
                        expansionIconAffinity: affinity,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Leading initially
      final double iconXBefore =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleXBefore = tester.getTopLeft(find.text('r0c0').first).dx;
      expect(iconXBefore, lessThan(titleXBefore));

      await tester.tap(find.text('SWITCH'));
      await tester.pumpAndSettle();

      final double iconXAfter =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double titleXAfter = tester.getTopLeft(find.text('r0c0').first).dx;
      expect(iconXAfter, greaterThan(titleXAfter));
    });
  });

  group('custom expansionIcon with leading affinity', () {
    testWidgets('custom icon is rendered instead of the default expand_more',
        (tester) async {
      const customIconData = Icons.chevron_right;

      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          themeData: ExpandableThemeData(
            expansionIcon: const Icon(customIconData, size: 20),
          ),
        ),
      );

      expect(find.byIcon(customIconData), findsWidgets);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('custom leading icon appears to the left of the title',
        (tester) async {
      const customIconData = Icons.chevron_right;

      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          themeData: ExpandableThemeData(
            expansionIcon: const Icon(customIconData, size: 20),
          ),
        ),
      );

      final double iconX =
          tester.getTopLeft(find.byIcon(customIconData).first).dx;
      final double titleX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(iconX, lessThan(titleX));
    });

    testWidgets('tapping custom leading icon expands the row', (tester) async {
      const customIconData = Icons.chevron_right;

      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          themeData: ExpandableThemeData(
            expansionIcon: const Icon(customIconData, size: 20),
          ),
        ),
      );

      expect(find.text('Col1:'), findsNothing);

      await tester.tap(find.byIcon(customIconData).first);
      await tester.pumpAndSettle();

      expect(find.text('Col1:'), findsOneWidget);
    });
  });

  group('editable table with leading affinity', () {
    testWidgets(
        'edit icon appears to the right of the title even when expansion icon is leading',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          isEditable: true,
        ),
      );

      final double editIconX =
          tester.getTopLeft(find.byIcon(Icons.edit).first).dx;
      final double titleX = tester.getTopLeft(find.text('r0c0').first).dx;

      expect(editIconX, greaterThan(titleX));
    });

    testWidgets(
        'both icons are visible: edit icon on the trailing side, '
        'expansion icon on the leading side', (tester) async {
      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          isEditable: true,
        ),
      );

      final double expansionIconX =
          tester.getTopLeft(find.byIcon(Icons.expand_more).first).dx;
      final double editIconX =
          tester.getTopLeft(find.byIcon(Icons.edit).first).dx;

      expect(expansionIconX, lessThan(editIconX));
    });

    testWidgets('edit icon is functional with leading affinity',
        (tester) async {
      await tester.pumpWidget(
        _buildTable(
          affinity: ListTileControlAffinity.leading,
          isEditable: true,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Default edit dialog should open
      expect(find.text('Edit Details'), findsOneWidget);
    });
  });
}
