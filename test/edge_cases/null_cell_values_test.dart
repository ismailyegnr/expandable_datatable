import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final headers = [
    ExpandableColumn<String>(columnTitle: 'Col 0', columnFlex: 1),
    ExpandableColumn<String>(columnTitle: 'Col 1', columnFlex: 1),
  ];

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

    testWidgets('nullValuePlaceholder is rendered for null cell values',
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
              nullValuePlaceholder: '-',
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(find.text('-'), findsWidgets);
      expect(find.text('null'), findsNothing);
    });
  });
}
