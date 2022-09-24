import 'package:flutter/material.dart';

import 'extension/context_extension.dart';
import 'model/cell_item.dart';
import 'model/expandable_column.dart';
import 'model/expandable_row.dart';
import 'model/sortable_row.dart';
import 'utility/sort_operations.dart';
import 'widget/custom_expansion_tile.dart' as custom_tile;
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

  /// Triggers when a row is edited with [ExpandableEditDialog].
  ///
  /// Returns the new [ExpandableRow] data.`
  final void Function(ExpandableRow newRow)? onRowChanged;

  /// When the current page is changed, this returns the new page value.
  ///
  final void Function(int page)? onPageChanged;

  /// Specifies the number of rows to be used on a single page.
  ///
  /// It defaults to 10.
  final int pageSize;

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
    Key? key,
    required this.rows,
    required this.headers,
    required this.visibleColumnCount,
    this.pageSize = 10,
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
  List<ExpandableColumn> _headerTitles = [];

  /// Stores the sorted state data of the data table.
  ///
  /// This helps for building.
  List<List<SortableRow>> _sortedRowsList = [];

  int _totalPageCount = 0;

  int _currentPage = 0;

  final SortOperations _sortOperations = SortOperations();

  late double _trailingWidth;

  int get pageLength =>
      _sortedRowsList.isNotEmpty ? _sortedRowsList[_currentPage].length : 0;

  @override
  void initState() {
    super.initState();

    _composeRowsList(widget.rows, isInit: true);
  }

  @override
  void didChangeDependencies() {
    _trailingWidth = context.dynamicWidth(0.15);

    super.didChangeDependencies();
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
    for (var element in rowData.cells) {
      if (headerNames.contains(element.columnTitle)) {
        int headerInd = _headerTitles
            .indexWhere((val) => val.columnTitle == element.columnTitle);

        titleCells.add(
          CellItem(
            columnName: element.columnTitle,
            value: element.value,
            flex: _headerTitles[headerInd].columnFlex,
          ),
        );
      } else {
        expansionCells.add(
          CellItem(
            columnName: element.columnTitle,
            value: element.value,
          ),
        );
      }
    }
  }

  /// Sort all rows.
  void _sortRows(ExpandableColumn column) {
    ///Resets the page and go back to first page.
    _currentPage = 0;

    List<SortableRow> tempSortArray =
        _sortOperations.sortAllRows(column, _sortedRowsList);

    _composeRowsList(tempSortArray);

    setState(() {});
  }

  /// Close expanded rows while page is changing.
  void _changePage(int newPage) {
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(newPage);
    }

    setState(() {
      _currentPage = newPage;
    });
  }

  /// Change a row after the row is edited with an edit dialog.
  void _updateRow(ExpandableRow newRow, int rowInd) {
    _sortedRowsList[_currentPage][rowInd].row = newRow;

    if (widget.onRowChanged != null) {
      widget.onRowChanged!(newRow);
    }

    setState(() {});
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
      child: ListView.builder(
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

  Container buildSingleRow(
    BuildContext context,
    int index,
    ExpandableRow row,
    List<CellItem> expansionCells,
    List<CellItem> titleCells,
  ) {
    var boxDecoration = BoxDecoration(
      border: Border(
        bottom: context.expandableTheme.rowBorder,
      ),
    );

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
      decoration: boxDecoration,
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: context.expandableTheme.expandedBorderColor,
        ),
        child: custom_tile.ExpansionTile(
          showExpansionIcon: expansionCells.isNotEmpty,
          expansionIcon: context.expandableTheme.expansionIcon,
          collapsedBackgroundColor:
              currentRowColor ?? context.expandableTheme.rowColor,
          backgroundColor: currentRowColor ?? context.expandableTheme.rowColor,
          trailingWidth: _trailingWidth,
          secondTrailing: buildEditIcon(context, index),
          title: buildRowTitleContent(titleCells),
          childrenPadding: EdgeInsets.symmetric(vertical: context.lowValue),
          children: buildExpansionContent(context, row, expansionCells),
        ),
      ),
    );
  }

  Widget buildHeader() {
    if (widget.headers.isNotEmpty) {
      _headerTitles = widget.headers.sublist(0, widget.visibleColumnCount);
    }

    return TableHeader(
      headerRow: _headerTitles,
      currentSort: _sortOperations.sortInformation,
      onTitleTap: _sortRows,
      trailingWidth: _trailingWidth,
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
      constraints: const BoxConstraints(),
      icon: context.expandableTheme.editIcon,
      onPressed: () => showEditDialog(context, rowInd),
    );
  }

  Future<dynamic> showEditDialog(BuildContext context, int rowInd) {
    return showDialog(
      context: context,
      builder: (context) => widget.renderEditDialog != null
          ? widget.renderEditDialog!(
              _sortedRowsList[_currentPage][rowInd].row,
              (newRow) => _updateRow(newRow, rowInd),
            )
          : EditDialog(
              row: _sortedRowsList[_currentPage][rowInd].row,
              onSuccess: (newRow) => _updateRow(newRow, rowInd),
            ),
    );
  }
}
