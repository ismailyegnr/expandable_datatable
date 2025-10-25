import 'dart:math';
import 'extension/context_extension.dart';
import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'model/cell_item.dart';
import 'model/expandable_cell.dart';
import 'model/expandable_column.dart';
import 'model/expandable_row.dart';
import 'utility/sort_utility.dart';
import 'widget/custom_expansion_tile.dart' as custom_tile;
import 'widget/edit/n_edit_dialog.dart';
import 'widget/pagination_widget.dart';
import 'widget/row_container.dart';
import 'widget/table_header.dart';

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

  /// Flag indicating that multiple expansions are enabled for rows.
  ///
  /// It defaults to true.
  final bool multipleExpansion;

  /// Flag indicating whether the rows are editable.
  /// If this value is false, renderEditDialog does not affect.
  ///
  /// It defaults to true.
  final bool isEditable;

  /// Triggers when a row is edited with [EditDialog].
  ///
  /// Returns the new [ExpandableRow] data.`
  final void Function(ExpandableRow newRow)? onRowChanged;

  /// When the current page is changed, [value] is the new page value.
  ///
  final void Function(int page)? onPageChanged;

  /// Specifies the number of rows to be used on a single page.
  ///
  /// It defaults to 10.
  final int pageSize;

  /// Renders a custom edit dialog widget with two parameters.
  ///
  /// Parameter [row], gives the current selected row information.
  ///
  /// Parameter [onSuccess], is a function and it must return a new
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
    Key? key,
    required this.headers,
    required this.rows,
    required this.visibleColumnCount,
    this.pageSize = 10,
    this.multipleExpansion = true,
    this.isEditable = true,
    this.onRowChanged,
    this.onPageChanged,
    this.renderEditDialog,
    this.renderCustomPagination,
    this.renderExpansionContent,
  })  : assert(visibleColumnCount > 0),
        assert(
          rows.isNotEmpty ? headers.length == rows.first.cells.length : true,
        ),
        super(key: key);

  @override
  State<ExpandableDataTable> createState() => _ExpandableDataTableState();
}

class _ExpandableDataTableState extends State<ExpandableDataTable> {
  final ScrollController _scrollController = ScrollController();
  late final SortUtil sortUtil;

  List<ExpandableColumn> shownCols = <ExpandableColumn>[];
  List<ExpandableColumn> unshownCols = <ExpandableColumn>[];

  List<ExpandableRow> get pageRows =>
      sortUtil.rows.sublist(currentPage * widget.pageSize, getUpperRange);

  int totalPages = 0;
  int currentPage = 0;
  int selectedRow = -1;

  int get getUpperRange =>
      min((currentPage + 1) * widget.pageSize, widget.rows.length);

  double get trailingWidth => context.dynamicWidth(widget.isEditable
      ? GeneralConstants.largeTrailing
      : GeneralConstants.smallTrailing);

  @override
  void initState() {
    super.initState();

    sortUtil = SortUtil(widget.rows);

    totalPages = (widget.rows.length / widget.pageSize).ceil();

    // Load shown and unshown accesor lists
    if (widget.headers.isNotEmpty) {
      for (int index = 0; index < widget.headers.length; index++) {
        if (index < widget.visibleColumnCount) {
          shownCols.add(widget.headers[index]);
        } else {
          unshownCols.add(widget.headers[index]);
        }
      }
    }
  }

  /// Creates shown cells and unshown cells list,
  /// using the current row's cell list
  (List<CellData>, List<CellData>) createRowCellDataLists(
    List<ExpandableCell> cellList,
  ) {
    List<CellData> currentRowShownCells = [];
    List<CellData> currentRowUnshownCells = [];

    for (ExpandableColumn colItem in shownCols) {
      ExpandableCell cellInfo = cellList
          .firstWhere((element) => colItem.accessor == element.accessor);
      currentRowShownCells.add(CellData(column: colItem, cell: cellInfo));
    }

    for (ExpandableColumn colItem in unshownCols) {
      ExpandableCell cellInfo = cellList
          .firstWhere((element) => colItem.accessor == element.accessor);
      currentRowUnshownCells.add(CellData(column: colItem, cell: cellInfo));
    }

    return (currentRowShownCells, currentRowUnshownCells);
  }

  /// Sort all rows and update page.
  void sortRows(ExpandableColumn column) {
    currentPage = 0;

    sortUtil.sort(column);

    setState(() {});
  }

  void shrinkAllRows() {
    if (selectedRow != -1) {
      selectedRow = -1;
    }
  }

  void changePage(int newPage) {
    /* if (widget.onPageChanged != null) {
      widget.onPageChanged!(newPage);
    } */

    currentPage = newPage;

    // shrinkAllRows();
    setState(() {});
  }

  /// Change a row after the row is edited with an edit dialog.
  void _updateRow(ExpandableRow newRow, int rowInd) {
    if (widget.onRowChanged != null) {
      widget.onRowChanged!(newRow);
    }

    setState(() {});
  }

  void changeExpanded(bool value, int rowIndex) {
    if (widget.multipleExpansion == false) {
      if (selectedRow == rowIndex && value == false) {
        selectedRow = -1;
      } else if (value == true) {
        setState(() {
          selectedRow = rowIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableHeader(
          sortData: sortUtil,
          headers: shownCols,
          onHeaderTap: sortRows,
          trailingWidth: trailingWidth,
        ),
        Expanded(
          child: buildAllPageRows(),
        ),
        buildPaginationWidget(context)
      ],
    );
  }

  Widget buildAllPageRows() {
    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: pageRows.length,
        itemBuilder: (context, index) =>
            buildSingleRow(context, index, pageRows[index]),
      ),
    );
  }

  Container buildSingleRow(BuildContext context, int index, ExpandableRow row) {
    var (shownCellsOfCurrentRow, unShownCellsOfCurrentRow) =
        createRowCellDataLists(row.cells);

    Color? currentRowColor;
    if (context.expandableTheme.evenRowColor != null &&
        context.expandableTheme.oddRowColor != null) {
      if (index % 2 == 0) {
        currentRowColor = context.expandableTheme.evenRowColor;
      } else {
        currentRowColor = context.expandableTheme.oddRowColor;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: context.expandableTheme.rowBorder,
        ),
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: context.expandableTheme.expandedBorderColor,
        ),
        child: custom_tile.ExpansionTile(
          tilePadding: context.expandableTheme.contentPadding,
          showExpansionIcon: unShownCellsOfCurrentRow.isNotEmpty,
          expansionIcon: context.expandableTheme.expansionIcon,
          collapsedBackgroundColor:
              currentRowColor ?? context.expandableTheme.rowColor,
          backgroundColor: currentRowColor ?? context.expandableTheme.rowColor,
          trailingWidth: trailingWidth,
          secondTrailing: widget.isEditable ? buildEditIcon(row) : null,
          onExpansionChanged: (value) => changeExpanded(value, index),
          initiallyExpanded: selectedRow == index,
          title: RowContainer(
            shownCells: shownCellsOfCurrentRow,
          ),
          childrenPadding: EdgeInsets.symmetric(vertical: context.lowValue),
          /* children: _buildExpansion(context, row, expansionCells), */
        ),
      ),
    );
  }

  Widget buildPaginationWidget(BuildContext context) {
    if (widget.renderCustomPagination != null) {
      return widget.renderCustomPagination!(
        totalPages,
        currentPage,
        (value) => changePage(value),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.lowValue),
      child: PaginationWidget(
        currentPage: currentPage,
        totalPageCount: totalPages,
        onChanged: (value) => changePage(value),
      ),
    );
  }

  Widget buildEditIcon(ExpandableRow row) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: context.expandableTheme.editIcon,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => NEditDialog(
            headers: widget.headers,
            row: row,
            onSaved: (cells) {
              setState(() {
                row.cells = cells;
              });
            },
          ),
        );
      },
    );
  }

  // TODO:: Build Expansion Container
}
