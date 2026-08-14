import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared helpers for building [ExpandableDataTable] instances in tests.
///
/// These mirror the private helpers that previously lived inside
/// `test/widget/edit_dialog_test.dart`, lifted here so the regression and
/// coverage suites can reuse them without duplication.

/// Wraps an editable [ExpandableDataTable] in a [MaterialApp]/[Scaffold] with an
/// optional [ExpandableTheme].
Widget buildEditableTable({
  required List<ExpandableRow> rows,
  required List<ExpandableColumn> headers,
  void Function(ExpandableRow, int)? onRowChanged,
  Widget Function(ExpandableRow, void Function(ExpandableRow))?
      renderEditDialog,
  int visibleColumnCount = 3,
  String? editDialogTitle,
  String? editSaveLabel,
  String? editCancelLabel,
  String nullValuePlaceholder = '',
  ExpandableThemeData themeData = const ExpandableThemeData(),
}) {
  return MaterialApp(
    home: Scaffold(
      body: ExpandableTheme(
        data: themeData,
        child: ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: visibleColumnCount,
          pageSize: 10,
          isEditable: true,
          nullValuePlaceholder: nullValuePlaceholder,
          onRowChanged: onRowChanged ?? (_, __) {},
          renderEditDialog: renderEditDialog,
          editDialogTitle: editDialogTitle,
          editSaveLabel: editSaveLabel,
          editCancelLabel: editCancelLabel,
        ),
      ),
    ),
  );
}

/// Builds a list of [String] columns from their titles.
List<ExpandableColumn<String>> strHeaders(List<String> names) => names
    .map((n) => ExpandableColumn<String>(columnTitle: n, columnFlex: 1))
    .toList();

/// Builds a single [ExpandableRow] of [String] cells.
ExpandableRow strRow(List<String> colNames, List<String?> values) =>
    ExpandableRow(
      cells: List.generate(
        colNames.length,
        (i) =>
            ExpandableCell<String>(columnTitle: colNames[i], value: values[i]),
      ),
    );

/// Finds the [TextFormField] belonging to the edit-dialog row whose label
/// [Text] equals [columnName].
Finder editFieldFor(String columnName) {
  final row = find.ancestor(
    of: find.text(columnName),
    matching: find.byType(Row),
  );
  return find.descendant(of: row, matching: find.byType(TextFormField));
}
