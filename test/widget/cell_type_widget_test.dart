import 'dart:typed_data';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

// 1×1 transparent PNG bytes.
final Uint8List _kTransparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

class CustomDateCellType extends CellType<DateTime> {
  const CustomDateCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(
      value != null ? 'DATE:${value.year}-${value.month}-${value.day}' : 'NO_DATE',
      key: const Key('custom_date_title'),
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(
      value != null ? 'EXP_DATE:${value.year}-${value.month}-${value.day}' : 'NO_DATE',
      key: const Key('custom_date_exp'),
    );
  }

  @override
  Widget? buildEditField(
    BuildContext context,
    DateTime? value,
    ValueChanged<DateTime?> onChanged, {
    bool isEditable = true,
    String? hintText,
    InputDecoration? baseDecoration,
  }) {
    return TextButton(
      key: const Key('custom_date_picker_button'),
      onPressed: isEditable
          ? () {
              onChanged(DateTime(2030, 12, 25));
            }
          : null,
      child: Text(
        value != null
            ? '${value.year}-${value.month}-${value.day}'
            : 'PICK_DATE',
      ),
    );
  }

  @override
  int compare(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }
}

void main() {
  group('CellType Widget Tests', () {
    testWidgets('Custom CellType renders in title cell and expansion cell',
        (tester) async {
      final headers = [
        ExpandableColumn<DateTime>(
          columnTitle: 'Created',
          columnFlex: 1,
          cellType: const CustomDateCellType(),
        ),
        ExpandableColumn<DateTime>(
          columnTitle: 'Updated',
          columnFlex: 1,
          cellType: const CustomDateCellType(),
        ),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<DateTime>(
              columnTitle: 'Created',
              value: DateTime(2026, 8, 14),
            ),
            ExpandableCell<DateTime>(
              columnTitle: 'Updated',
              value: DateTime(2026, 8, 15),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 1, // 'Updated' goes to expansion
        )),
      );

      // Visible column 'Created' uses buildTitleCell
      expect(find.text('DATE:2026-8-14'), findsOneWidget);

      // Expand row
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // Expansion column 'Updated' uses buildExpansionCell
      expect(find.text('EXP_DATE:2026-8-15'), findsOneWidget);
    });

    testWidgets('ImageCellType renders with custom height, fit, and borderRadius',
        (tester) async {
      final headers = [
        ExpandableColumn<ImageProvider>(
          columnTitle: 'Avatar',
          columnFlex: 1,
          cellType: const ImageCellType(
            height: 75,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ];

      final imgProvider = MemoryImage(_kTransparentImage);

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<ImageProvider>(
              columnTitle: 'Avatar',
              value: imgProvider,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 1,
        )),
      );

      // Check ClipRRect and Image
      expect(find.byType(ClipRRect), findsOneWidget);
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(
        clipRRect.borderRadius,
        const BorderRadius.all(Radius.circular(16)),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      expect(image.fit, BoxFit.cover);
      expect(image.image, equals(imgProvider));
    });

    testWidgets('Precedence: cellBuilder overrides cellType', (tester) async {
      final headers = [
        ExpandableColumn<DateTime>(
          columnTitle: 'DateCol',
          columnFlex: 1,
          cellType: const CustomDateCellType(),
          cellBuilder: (context, value) => Text('BUILDER:${value.toString()}'),
        ),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<DateTime>(
              columnTitle: 'DateCol',
              value: DateTime(2026, 1, 1),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 1,
        )),
      );

      expect(find.text('BUILDER:2026-01-01 00:00:00.000'), findsOneWidget);
      expect(find.text('DATE:2026-1-1'), findsNothing);
    });

    testWidgets('Sorting by column with custom CellType uses cellType.compare',
        (tester) async {
      final headers = [
        ExpandableColumn<DateTime>(
          columnTitle: 'Date',
          columnFlex: 1,
          cellType: const CustomDateCellType(),
        ),
        ExpandableColumn<String>(
          columnTitle: 'Label',
          columnFlex: 1,
        ),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<DateTime>(
              columnTitle: 'Date',
              value: DateTime(2026, 12, 1),
            ),
            ExpandableCell<String>(
              columnTitle: 'Label',
              value: 'RowLater',
            ),
          ],
        ),
        ExpandableRow(
          cells: [
            ExpandableCell<DateTime>(
              columnTitle: 'Date',
              value: DateTime(2025, 1, 1),
            ),
            ExpandableCell<String>(
              columnTitle: 'Label',
              value: 'RowEarlier',
            ),
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

      // Initial order: RowLater, RowEarlier
      final labelsBefore = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .where((d) => d == 'RowLater' || d == 'RowEarlier')
          .toList();
      expect(labelsBefore, ['RowLater', 'RowEarlier']);

      // Tap header on 'Date' column to sort ASC
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();

      // After sorting ASC: RowEarlier (2025), RowLater (2026)
      final labelsAfterAsc = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .where((d) => d == 'RowLater' || d == 'RowEarlier')
          .toList();
      expect(labelsAfterAsc, ['RowEarlier', 'RowLater']);
    });

    testWidgets('Editing row with CellType.buildEditField updates and saves value',
        (tester) async {
      final headers = [
        ExpandableColumn<DateTime>(
          columnTitle: 'Date',
          columnFlex: 1,
          cellType: const CustomDateCellType(),
        ),
      ];

      final rows = [
        ExpandableRow(
          cells: [
            ExpandableCell<DateTime>(
              columnTitle: 'Date',
              value: DateTime(2020, 1, 1),
            ),
          ],
        ),
      ];

      ExpandableRow? savedRow;
      int? savedIndex;

      await tester.pumpWidget(
        _wrap(ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 1,
          isEditable: true,
          onRowChanged: (newRow, originalIndex) {
            savedRow = newRow;
            savedIndex = originalIndex;
          },
        )),
      );

      // Tap edit button to open EditDialog
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Custom button from CustomDateCellType.buildEditField is present
      expect(find.byKey(const Key('custom_date_picker_button')), findsOneWidget);
      expect(find.text('2020-1-1'), findsOneWidget);

      // Tap button to change date to 2030-12-25
      await tester.tap(find.byKey(const Key('custom_date_picker_button')));
      await tester.pumpAndSettle();

      expect(find.text('2030-12-25'), findsOneWidget);

      // Tap SAVE
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(savedIndex, 0);
      expect(savedRow, isNotNull);
      expect(savedRow!.cells.first.value, DateTime(2030, 12, 25));
    });
  });
}
