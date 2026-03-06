import 'dart:typed_data';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1×1 transparent PNG — minimal valid image bytes usable in widget tests.
final Uint8List _kTransparentImage = Uint8List.fromList([
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
]);

MemoryImage _makeImage() => MemoryImage(_kTransparentImage);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Title row
  // -------------------------------------------------------------------------

  group('title row — ImageProvider cell', () {
    testWidgets('renders an Image widget instead of a Text for the cell value',
        (tester) async {
      final provider = _makeImage();

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 1,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<ImageProvider>(
                    columnTitle: 'Avatar',
                    value: provider,
                  ),
                ],
              ),
            ],
            visibleColumnCount: 1,
            pageSize: 10,
          ),
        ),
      );

      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Image && w.image == provider),
        findsOneWidget,
      );
      // The raw toString of the provider must not appear as a Text widget.
      expect(find.textContaining('MemoryImage'), findsNothing);
    });

    testWidgets('non-image cells still render as Text', (tester) async {
      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 1),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(
                    columnTitle: 'Name',
                    value: 'Alice',
                  ),
                ],
              ),
            ],
            visibleColumnCount: 1,
            pageSize: 10,
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Expansion area
  // -------------------------------------------------------------------------

  group('expansion area — ImageProvider cell', () {
    testWidgets('does not show Image widget before row is expanded',
        (tester) async {
      final provider = _makeImage();

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 1, // Name visible; Avatar goes to expansion
            pageSize: 10,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate((w) => w is Image && w.image == provider),
        findsNothing,
      );
    });

    testWidgets('renders Image widget after row is expanded', (tester) async {
      final provider = _makeImage();

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 1,
            pageSize: 10,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is Image && w.image == provider),
        findsOneWidget,
      );
    });

    testWidgets(
        'expansion area shows label but no Text value for ImageProvider cell',
        (tester) async {
      final provider = _makeImage();

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 1,
            pageSize: 10,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // The column label is shown.
      expect(find.text('Avatar:'), findsOneWidget);
      // The provider's toString must never appear.
      expect(find.text(provider.toString()), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Edit dialog
  // -------------------------------------------------------------------------

  group('edit dialog — ImageProvider cell', () {
    testWidgets(
        'shows image preview widget instead of a TextFormField for the cell',
        (tester) async {
      final provider = _makeImage();

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 2,
            pageSize: 10,
            isEditable: true,
            onRowChanged: (_, __) {},
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Image preview is rendered for the Avatar cell (the title row may also
      // show the same provider, so we assert at least one Image is present).
      expect(
        find.byWidgetPredicate((w) => w is Image && w.image == provider),
        findsAtLeastNWidgets(1),
      );
      // Only Name has a TextFormField; Avatar must not have one.
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('SAVE preserves the original ImageProvider instance',
        (tester) async {
      final provider = _makeImage();
      ExpandableRow? saved;

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 2,
            pageSize: 10,
            isEditable: true,
            onRowChanged: (row, _) => saved = row,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      final avatarCell =
          saved!.cells.firstWhere((c) => c.columnTitle == 'Avatar');
      // The exact same ImageProvider instance must be returned.
      expect(avatarCell.value, same(provider));
    });

    testWidgets('SAVE with modified Name preserves ImageProvider alongside',
        (tester) async {
      final provider = _makeImage();
      ExpandableRow? saved;

      await tester.pumpWidget(
        _host(
          ExpandableDataTable(
            headers: [
              ExpandableColumn<String>(columnTitle: 'Name', columnFlex: 2),
              ExpandableColumn<ImageProvider>(
                columnTitle: 'Avatar',
                columnFlex: 2,
                isEditable: false,
              ),
            ],
            rows: [
              ExpandableRow(
                cells: [
                  ExpandableCell<String>(columnTitle: 'Name', value: 'Alice'),
                  ExpandableCell<ImageProvider>(
                      columnTitle: 'Avatar', value: provider),
                ],
              ),
            ],
            visibleColumnCount: 2,
            pageSize: 10,
            isEditable: true,
            onRowChanged: (row, _) => saved = row,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      // Modify the Name field.
      final nameRow = find.ancestor(
        of: find.text('Name'),
        matching: find.byType(Row),
      );
      final nameField = find.descendant(
        of: nameRow,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(nameField, 'Bob');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(saved, isNotNull);
      final nameCell = saved!.cells.firstWhere((c) => c.columnTitle == 'Name');
      final avatarCell =
          saved!.cells.firstWhere((c) => c.columnTitle == 'Avatar');

      expect(nameCell.value, 'Bob');
      expect(avatarCell.value, same(provider));
    });
  });
}
