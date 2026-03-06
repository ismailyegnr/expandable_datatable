import 'dart:math';

import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'extension/context_extension.dart';
import 'model/cell_item.dart';
import 'model/expandable_column.dart';
import 'model/expandable_row.dart';
import 'model/sortable_row.dart';
import 'utility/expandable_theme.dart';
import 'utility/sort_operations.dart';
import 'widget/custom_expansible.dart' as custom_expansible;
import 'widget/edit_dialog.dart';
import 'widget/expansion_container.dart';
import 'widget/pagination_widget.dart';
import 'widget/table_header.dart';
import 'widget/title_container.dart';

class ExpandableDataTable extends StatefulWidget {
  /// The data of rows
  final List<ExpandableRow> rows;

  /// Headers row generates the header row of the datatable. Header's columns data
  /// creates a template for all rows.
  final List<ExpandableColumn> headers;

  /// This determines how many columns will appear for that build and the data
  /// for the remaining columns are stored in the expansion widget.
  ///
  /// This parameter can be work compatible with [LayoutBuilder].
  ///
  /// ```dart
  /// return LayoutBuilder(
  ///   builder: (context, constraints) {
  ///     int visibleCount = 3;
  ///     if (constraints.maxWidth < 600) {
  ///       visibleCount = 3;
  ///     } else if (constraints.maxWidth < 800) {
  ///       visibleCount = 4;
  ///     } else if (constraints.maxWidth < 1000) {
  ///       visibleCount = 5;
  ///     } else {
  ///       visibleCount = 6;
  ///     }
  ///
  ///     return ExpandableDataTable(
  ///       visibleColumnCount: visibleCount,
  ///       ...
  ///     );
  /// ```
  ///
  final int visibleColumnCount;

  /// Controls where the expansion arrow icon appears on each row.
  ///
  /// Use [ListTileControlAffinity.leading] to show the icon on the left side
  /// and [ListTileControlAffinity.trailing] (the default) to show it on the
  /// right side.
  ///
  /// It defaults to [ListTileControlAffinity.trailing].
  final ListTileControlAffinity expansionIconAffinity;

  /// Flag indicating that multiple expansions are enabled for rows.
  ///
  /// It defaults to true.
  final bool multipleExpansion;

  /// Flag indicating whether the rows are editable.
  /// If this value is false, renderEditDialog does not affect.
  ///
  /// It defaults to false.
  final bool isEditable;

  /// Triggers when a row is edited with [EditDialog].
  ///
  /// Returns the new [ExpandableRow] data and the index of the row
  /// in the original list provided to [rows].
  final void Function(ExpandableRow newRow, int originalIndex)? onRowChanged;

  /// When the current page is changed, this returns the new page value.
  ///
  final void Function(int page)? onPageChanged;

  /// Specifies the number of rows to be used on a single page.
  ///
  /// It defaults to 10.
  final int pageSize;

  /// Title text shown at the top of the default [EditDialog].
  ///
  /// Defaults to `'Edit Details'`.
  final String? editDialogTitle;

  /// Label for the save action button in the default [EditDialog].
  ///
  /// Defaults to `'SAVE'`.
  final String? editSaveLabel;

  /// Label for the cancel action button in the default [EditDialog].
  ///
  /// Defaults to `'CANCEL'`.
  final String? editCancelLabel;

  /// Placeholder string to display when a cell's value is null.
  ///
  /// Defaults to an empty string ("") if not provided.
  final String nullValuePlaceholder;

  /// Renders a custom edit dialog widget with two parameters.
  ///
  /// First parameter, row, gives the current selected row information.
  ///
  /// Second parameter, onSuccess, is a function and it must return a new
  /// [ExpandableRow] variable to update the value of the row inside the widget.
  ///
  /// ```dart
  /// renderEditDialog: (row, onSuccess) {
  ///   return AlertDialog(
  ///     title: SizedBox(
  ///       height: 300,
  ///       child: TextButton(
  ///         child: const Text("Change Row"),
  ///         onPressed: () {
  ///           row.cells[1].value = "New Value";
  ///           onSuccess(row);
  ///          },
  ///       ),
  ///     ),
  ///   );
  /// }
  ///```
  final Widget Function(
    ExpandableRow row,
    void Function(ExpandableRow newRow) onSuccess,
  )? renderEditDialog;

  /// Renders a custom pagination widget with three parameters.
  ///
  /// First parameter, count, returns the total page count of the datatable.
  ///
  /// Second parameter, page, returns the current page value.
  ///
  /// Last parameter, onChange, is a function and it must return a new
  /// integer page variable to update the value of the current page.
  /// ```dart
  /// renderCustomPagination: (count, page, onChange) {
  ///   return Row(
  ///     mainAxisAlignment: MainAxisAlignment.spaceAround,
  ///     children: [
  ///       TextButton(
  ///         onPressed: () {
  ///           if (page > 0) {
  ///             onChange(page - 1);
  ///           }
  ///         },
  ///         child: const Text("Previous"),
  ///       ),
  ///       Text("Total: $count"),
  ///       Text("Current index: $page"),
  ///       TextButton(
  ///         onPressed: () {
  ///           if (page < count - 1) {
  ///             onChange(page + 1);
  ///           }
  ///         },
  ///         child: const Text("Next"),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  final Widget Function(
    int count,
    int page,
    void Function(int page) onChange,
  )? renderCustomPagination;

  /// Renders a custom expansion content widget.
  ///
  /// This gives the all row information with row parameter, and it expects a
  /// widget.
  /// ```dart
  /// renderExpansionContent: (row) {
  ///   return Text(row.cells[0].columnTitle);
  /// }
  /// ```
  final Widget Function(
    ExpandableRow row,
  )? renderExpansionContent;

  ExpandableDataTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.visibleColumnCount,
    this.pageSize = 10,
    this.expansionIconAffinity = ListTileControlAffinity.trailing,
    this.multipleExpansion = true,
    this.isEditable = false,
    this.onRowChanged,
    this.onPageChanged,
    this.editDialogTitle,
    this.editSaveLabel,
    this.editCancelLabel,
    this.nullValuePlaceholder = '',
    this.renderEditDialog,
    this.renderCustomPagination,
    this.renderExpansionContent,
  })  : assert(visibleColumnCount > 0),
        assert(pageSize > 0),
        assert(
          rows.isNotEmpty ? headers.length == rows.first.cells.length : true,
        ),
        assert(
          !isEditable || onRowChanged != null,
          'If isEditable is true, onRowChanged must be provided to handle data updates.',
        );

  @override
  State<ExpandableDataTable> createState() => _ExpandableDataTableState();
}

class _ExpandableDataTableState extends State<ExpandableDataTable> {
  final ScrollController _scrollController = ScrollController();
  final SortOperations _sortOperations = SortOperations();

  List<ExpandableColumn> _headerTitles = [];

  /// Stores the sorted state data of the data table.
  ///
  /// This helps for building.
  List<List<SortableRow>> _sortedRowsList = [];

  int _totalPageCount = 0;
  int _currentPage = 0;
  int _selectedRow = -1;

  /// Incremented every time all rows should collapse.
  ///
  /// Used as part of each tile's [Key] so that Flutter recreates the tile
  /// widget (and its internal [ExpansibleController]) in the collapsed state
  /// whenever the epoch changes. This ensures both [multipleExpansion] modes
  /// collapse rows consistently on page change, sort, or data update.
  int _expansionEpoch = 0;

  int get pageLength =>
      _sortedRowsList.isNotEmpty ? _sortedRowsList[_currentPage].length : 0;

  @override
  void initState() {
    super.initState();

    _updateHeaderTitles();
    _composeRowsList(widget.rows, isInit: true);
  }

  @override
  void didUpdateWidget(covariant ExpandableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Flag to control the single setState at the end
    bool shouldSetState = false;

    // Re-compose the internal row list if the data source (rows), pagination
    // configuration (pageSize), columns (headers), or visible column count changes.
    if (widget.rows != oldWidget.rows ||
        widget.pageSize != oldWidget.pageSize ||
        widget.headers != oldWidget.headers ||
        widget.visibleColumnCount != oldWidget.visibleColumnCount) {
      _updateHeaderTitles();

      // Rebuild internal data structure for pagination
      _composeRowsList(widget.rows, isInit: true);

      // Re-apply sort if one was active
      _reApplySort();

      _shrinkAllRows();

      shouldSetState = true;
    }

    if (shouldSetState) {
      setState(() {});
    }
  }

  void _updateHeaderTitles() {
    if (widget.headers.isNotEmpty) {
      _headerTitles = widget.headers
          .sublist(0, min(widget.visibleColumnCount, widget.headers.length));
    }
  }

  /// Create or update two dimension sorted rows list
  void _composeRowsList(List<dynamic> list, {bool isInit = false}) {
    _totalPageCount = 0;
    _sortedRowsList = [];

    for (int i = 0; i < list.length; i++) {
      if (i % widget.pageSize == 0) {
        _totalPageCount++;
        _sortedRowsList.add([]);
      }

      _sortedRowsList[_totalPageCount - 1].add(
        isInit ? SortableRow(i, row: list[i]) : list[i],
      );
    }
  }

  /// Handles the row data by, loading titleCells and expansionCells lists for
  /// expansion tiles.
  void _createRowCells(
    List<String> headerNames,
    ExpandableRow rowData,
    List<CellItem> titleCells,
    List<CellItem> expansionCells,
  ) {
    final String placeholder = widget.nullValuePlaceholder;

    for (var element in rowData.cells) {
      // Preserve ImageProvider objects as-is; convert everything else to String.
      final dynamic displayValue = element.value is ImageProvider
          ? element.value
          : (element.value?.toString() ?? placeholder);

      if (headerNames.contains(element.columnTitle)) {
        int headerInd = _headerTitles
            .indexWhere((val) => val.columnTitle == element.columnTitle);

        titleCells.add(
          CellItem(
            columnName: element.columnTitle,
            value: displayValue,
            flex: _headerTitles[headerInd].columnFlex,
          ),
        );
      } else {
        expansionCells.add(
          CellItem(
            columnName: element.columnTitle,
            value: displayValue,
          ),
        );
      }
    }
  }

  /// Sort rows by selected column.
  void _sortRowsByColumn(ExpandableColumn column) {
    // Resets the page and go back to first page.
    _currentPage = 0;

    // Change sort direction.
    _sortOperations.changeSortDirection(column);

    List<SortableRow> tempSortArray =
        _sortOperations.sortAllRows(column, _sortedRowsList);

    _composeRowsList(tempSortArray);

    _shrinkAllRows();

    setState(() {});
  }

  /// Re-applies the last active sort to the current data set if one is active.
  void _reApplySort() {
    final column = _sortOperations.sortInformation.sortedColumn;

    if (column != null) {
      List<SortableRow> tempSortArray =
          _sortOperations.sortAllRows(column, _sortedRowsList);

      _composeRowsList(tempSortArray);
    }
  }

  void _shrinkAllRows() {
    _selectedRow = -1;
    _expansionEpoch++;
  }

  /// Close expanded rows while page is changing.
  void _changePage(int newPage) {
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(newPage);
    }

    _shrinkAllRows();

    setState(() {
      _currentPage = newPage;
    });
  }

  /// Change a row after the row is edited with an edit dialog.
  ///
  /// Stateless Approach: No internal changes
  void _updateRow(ExpandableRow newRow, int rowInd) {
    if (widget.onRowChanged != null) {
      final originalIndex = _sortedRowsList[_currentPage][rowInd].index;
      widget.onRowChanged!(newRow, originalIndex);
    }
  }

  void _onExpansionChanged(bool value, int rowIndex) {
    if (widget.multipleExpansion == false) {
      if (_selectedRow == rowIndex && value == false) {
        _selectedRow = -1;
      } else if (value == true) {
        setState(() {
          _selectedRow = rowIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        Expanded(
          child: buildRows(),
        ),
        buildPagination(context)
      ],
    );
  }

  Widget buildPagination(BuildContext context) {
    return widget.renderCustomPagination != null
        ? widget.renderCustomPagination!(
            _totalPageCount,
            _currentPage,
            (value) => _changePage(value),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: context.lowValue),
            child: PaginationWidget(
              currentPage: _currentPage,
              totalPageCount: _totalPageCount,
              onChanged: (value) => _changePage(value),
            ),
          );
  }

  Widget buildRows() {
    List<String> headerNames = [];

    for (var element in _headerTitles) {
      headerNames.add(element.columnTitle);
    }

    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: pageLength,
        itemBuilder: (context, index) {
          //gets current index value of sorted data list
          ExpandableRow rowData =
              _sortedRowsList[_currentPage].elementAt(index).row;

          List<CellItem> expansionCells = [];
          List<CellItem> titleCells = [];

          _createRowCells(headerNames, rowData, titleCells, expansionCells);

          return buildSingleRow(
              context, index, rowData, expansionCells, titleCells);
        },
      ),
    );
  }

  custom_expansible.ExpansionTile buildSingleRow(
    BuildContext context,
    int index,
    ExpandableRow row,
    List<CellItem> expansionCells,
    List<CellItem> titleCells,
  ) {
    Color currentRowColor = context.expandableTheme.rowColor ??
        Theme.of(context).colorScheme.surface;

    if (context.expandableTheme.evenRowColor != null &&
        context.expandableTheme.oddRowColor != null) {
      if (index % 2 == 0) {
        currentRowColor = context.expandableTheme.evenRowColor!;
      } else {
        currentRowColor = context.expandableTheme.oddRowColor!;
      }
    }

    return custom_expansible.ExpansionTile(
      key: ValueKey('$_expansionEpoch-$index'),
      showTrailingIcon: expansionCells.isNotEmpty,
      collapsedBackgroundColor: currentRowColor,
      backgroundColor:
          context.expandableTheme.expandedBackgroundColor ?? currentRowColor,
      onExpansionChanged: (value) => _onExpansionChanged(value, index),
      initiallyExpanded: _selectedRow == index,
      controlAffinity: widget.expansionIconAffinity,
      title: buildRowTitleContent(titleCells),
      secondTrailing: widget.isEditable ? buildEditIcon(context, index) : null,
      children: buildExpansionContent(context, row, expansionCells),
    );
  }

  Widget buildHeader() {
    return TableHeader(
      headerRow: _headerTitles,
      currentSort: _sortOperations.sortInformation,
      onTitleTap: _sortRowsByColumn,
      isEditable: widget.isEditable,
      isLeadingExpansion:
          widget.expansionIconAffinity == ListTileControlAffinity.leading,
    );
  }

  Widget buildRowTitleContent(List<CellItem> titleCells) {
    return TitleContainer(
      titleCells: titleCells,
    );
  }

  List<Widget> buildExpansionContent(
    BuildContext context,
    ExpandableRow row,
    List<CellItem> expansionCells,
  ) {
    if (expansionCells.isEmpty) {
      return [];
    } else if (widget.renderExpansionContent != null) {
      return [
        widget.renderExpansionContent!(row),
      ];
    }

    return [
      ExpansionContainer(expansionCells: expansionCells),
    ];
  }

  Widget buildEditIcon(BuildContext context, int rowInd) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: context.expandableTheme.editIcon ??
          Icon(
            Icons.edit,
            size: GeneralConstants.defaultEditIconSize,
          ),
      onPressed: () => showEditDialog(context, rowInd),
    );
  }

  Future<dynamic> showEditDialog(BuildContext context, int rowInd) {
    // Capture the theme from the current (state) context before the dialog
    // opens, so it is accessible inside the dialog's overlay context.
    final themeData = context.expandableTheme;
    final row = _sortedRowsList[_currentPage][rowInd].row;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        final content = widget.renderEditDialog != null
            ? widget.renderEditDialog!(
                row,
                (newRow) => _updateRow(newRow, rowInd),
              )
            : EditDialog(
                row: row,
                columns: widget.headers,
                onSuccess: (newRow) => _updateRow(newRow, rowInd),
                title: widget.editDialogTitle ?? 'Edit Details',
                saveLabel: widget.editSaveLabel ?? 'SAVE',
                cancelLabel: widget.editCancelLabel ?? 'CANCEL',
              );

        return ExpandableTheme(data: themeData, child: content);
      },
    );
  }
}
