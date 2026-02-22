import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../exception/no_support_exception.dart';
import '../extension/context_extension.dart';
import '../extension/string_extension.dart';
import '../model/expandable_column.dart';
import '../model/expandable_row.dart';

class EditDialog extends StatefulWidget {
  final ExpandableRow row;
  final List<ExpandableColumn> columns;
  final Function(ExpandableRow newRow) onSuccess;

  /// Title displayed at the top of the dialog.
  ///
  /// Defaults to `'Edit Details'`.
  final String title;

  /// Label for the save action button.
  ///
  /// Defaults to `'SAVE'`.
  final String saveLabel;

  /// Label for the cancel action button.
  ///
  /// Defaults to `'CANCEL'`.
  final String cancelLabel;

  const EditDialog({
    super.key,
    required this.row,
    required this.columns,
    required this.onSuccess,
    this.title = 'Edit Details',
    this.saveLabel = 'SAVE',
    this.cancelLabel = 'CANCEL',
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  List<TextEditingController> controllers = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ExpandableCell<dynamic>> get rowCells => widget.row.cells;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < rowCells.length; i++) {
      controllers.add(TextEditingController());
    }

    _initTextFields();
  }

  void _initTextFields() {
    for (int i = 0; i < rowCells.length; i++) {
      controllers[i].text = rowCells[i].value.toString();
    }
  }

  @override
  void dispose() {
    for (var element in controllers) {
      element.dispose();
    }

    super.dispose();
  }

  ExpandableColumn? _columnFor(ExpandableCell<dynamic> cell) {
    try {
      return widget.columns
          .firstWhere((col) => col.columnTitle == cell.columnTitle);
    } catch (_) {
      return null;
    }
  }

  void _processCellUpdate() {
    if (_formKey.currentState!.validate()) {
      List<ExpandableCell> resultCellList = [];

      for (int i = 0; i < rowCells.length; i++) {
        final ExpandableCell oldCell = rowCells[i];
        final ExpandableColumn? col = _columnFor(oldCell);
        final bool editable = col?.isEditable ?? true;

        if (!editable) {
          // Preserve the original cell value unchanged.
          resultCellList.add(
            ExpandableCell(
              columnTitle: oldCell.columnTitle,
              value: oldCell.value,
            ),
          );
          continue;
        }

        if (oldCell.value is String) {
          resultCellList.add(
            ExpandableCell<String>(
              columnTitle: oldCell.columnTitle,
              value: controllers[i].text,
            ),
          );
        } else if (oldCell.value is bool) {
          resultCellList.add(
            ExpandableCell<bool>(
              columnTitle: oldCell.columnTitle,
              value: controllers[i].text.parseToBool,
            ),
          );
        } else if (oldCell.value is int) {
          resultCellList.add(
            ExpandableCell<int>(
              columnTitle: oldCell.columnTitle,
              value: int.parse(controllers[i].text),
            ),
          );
        } else if (oldCell.value is double) {
          resultCellList.add(
            ExpandableCell<double>(
              columnTitle: oldCell.columnTitle,
              value: double.parse(controllers[i].text),
            ),
          );
        } else {
          throw NoSupportException(oldCell.value.runtimeType.toString());
        }
      }

      widget.onSuccess(ExpandableRow(cells: resultCellList));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.expandableTheme;

    return AlertDialog(
      scrollable: true,
      backgroundColor: theme.editDialogBackgroundColor,
      shape: theme.editDialogShape,
      title: Text(
        widget.title,
        style: theme.editDialogTitleStyle,
      ),
      actions: _buildActionButtons(theme),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: _buildContent(theme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(dynamic theme) {
    return <Widget>[
      TextButton(
        onPressed: _processCellUpdate,
        child: Text(
          widget.saveLabel,
          style: theme.editSaveButtonTextStyle ??
              const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          widget.cancelLabel,
          style: theme.editCancelButtonTextStyle ??
              const TextStyle(color: Colors.cyan),
        ),
      ),
    ];
  }

  Widget _buildContent(dynamic theme) {
    final List<Widget> widgets = [];

    for (int i = 0; i < rowCells.length; i++) {
      final ExpandableColumn? col = _columnFor(rowCells[i]);

      widgets.add(
        EditRow(
          controller: controllers[i],
          columnName: rowCells[i].columnTitle,
          valueType: rowCells[i].value.runtimeType,
          isEditable: col?.isEditable ?? true,
          hintText: col?.hintText,
          baseDecoration: theme.editInputDecoration,
        ),
      );
    }

    return Column(children: widgets);
  }
}

class EditRow extends StatefulWidget {
  final TextEditingController controller;
  final String columnName;
  final Type valueType;

  /// Whether this field is interactive. Disabled fields show the current value
  /// but cannot be modified.
  final bool isEditable;

  /// Optional hint text shown inside the input field.
  final String? hintText;

  /// Base [InputDecoration] from the theme, merged with [hintText].
  final InputDecoration? baseDecoration;

  const EditRow({
    super.key,
    required this.controller,
    required this.columnName,
    required this.valueType,
    this.isEditable = true,
    this.hintText,
    this.baseDecoration,
  });

  @override
  State<EditRow> createState() => _EditRowState();
}

class _EditRowState extends State<EditRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(widget.columnName),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: widget.valueType == bool
                ? _buildBoolInput(widget.controller)
                : _buildTextInput(widget.controller),
          ),
        ),
      ],
    );
  }

  InputDecoration _resolvedDecoration() {
    final base = widget.baseDecoration ?? const InputDecoration();
    return widget.hintText != null
        ? base.copyWith(hintText: widget.hintText)
        : base;
  }

  Widget _buildTextInput(TextEditingController controller) {
    List<TextInputFormatter>? formatters;
    if (widget.valueType == int) {
      formatters = [FilteringTextInputFormatter.digitsOnly];
    } else if (widget.valueType == double) {
      formatters = [
        FilteringTextInputFormatter.allow(
          RegExp(GeneralConstants.DOUBLE_REGEXP),
        ),
      ];
    }

    return TextFormField(
      keyboardType: formatters != null ? TextInputType.number : null,
      inputFormatters: formatters,
      enabled: widget.isEditable,
      decoration: _resolvedDecoration(),
      validator: (String? value) {
        if (!widget.isEditable) return null;
        if (value!.isEmpty) return 'Field must not be empty';
        return null;
      },
      controller: controller,
    );
  }

  Widget _buildBoolInput(TextEditingController controller) {
    String dropdownVal = controller.text;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: dropdownVal,
        onChanged: widget.isEditable
            ? (String? newValue) {
                setState(() {
                  controller.text = newValue!;
                  dropdownVal = controller.text;
                });
              }
            : null,
        items: <String>['true', 'false'].map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          },
        ).toList(),
      ),
    );
  }
}
