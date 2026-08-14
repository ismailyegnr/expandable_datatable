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
  final Map<int, dynamic> _cellValues = {};
  final Set<int> _customFieldIndices = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ExpandableCell<dynamic>> get rowCells => widget.row.cells;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < rowCells.length; i++) {
      controllers.add(TextEditingController());
      _cellValues[i] = rowCells[i].value;
    }

    _initTextFields();
  }

  void _initTextFields() {
    for (int i = 0; i < rowCells.length; i++) {
      final dynamic value = rowCells[i].value;

      // ImageProvider cannot be meaningfully serialized to text, and a null
      // value has no useful string representation — leave the controller
      // empty in both cases rather than showing the literal "null".
      controllers[i].text =
          (value == null || value is ImageProvider) ? '' : value.toString();
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

        if (_customFieldIndices.contains(i)) {
          resultCellList.add(
            ExpandableCell(
              columnTitle: oldCell.columnTitle,
              value: _cellValues[i],
            ),
          );
          continue;
        }

        // A null cell value carries no runtime type information, so fall
        // back to the column's declared generic type instead of throwing
        // NoSupportException.
        final Type effectiveType =
            oldCell.value?.runtimeType ?? col?.type ?? Null;
        final String text = controllers[i].text;

        if (oldCell.value is ImageProvider || effectiveType == ImageProvider) {
          // ImageProvider is never editable via text; preserve original value unconditionally.
          resultCellList.add(
            ExpandableCell(
              columnTitle: oldCell.columnTitle,
              value: oldCell.value,
            ),
          );
        } else if (effectiveType == String) {
          resultCellList.add(
            ExpandableCell<String>(
              columnTitle: oldCell.columnTitle,
              value: text,
            ),
          );
        } else if (effectiveType == bool) {
          resultCellList.add(
            ExpandableCell<bool>(
              columnTitle: oldCell.columnTitle,
              value: text.isEmpty ? null : text.parseToBool,
            ),
          );
        } else if (effectiveType == int) {
          resultCellList.add(
            ExpandableCell<int>(
              columnTitle: oldCell.columnTitle,
              value: text.isEmpty ? null : int.tryParse(text),
            ),
          );
        } else if (effectiveType == double) {
          resultCellList.add(
            ExpandableCell<double>(
              columnTitle: oldCell.columnTitle,
              value: text.isEmpty ? null : double.tryParse(text),
            ),
          );
        } else {
          throw NoSupportException(effectiveType.toString());
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
    _customFieldIndices.clear();

    for (int i = 0; i < rowCells.length; i++) {
      final ExpandableColumn? col = _columnFor(rowCells[i]);
      final dynamic cellValue = _cellValues[i];

      Widget? customEditWidget;
      if (col?.cellType != null) {
        customEditWidget = col!.cellType!.buildEditField(
          context,
          cellValue,
          (newValue) {
            setState(() {
              _cellValues[i] = newValue;
              if (newValue != null && newValue is! ImageProvider) {
                controllers[i].text = newValue.toString();
              }
            });
          },
          isEditable: col.isEditable,
          hintText: col.hintText,
          baseDecoration: theme.editInputDecoration,
        );
      }

      if (customEditWidget != null) {
        _customFieldIndices.add(i);
        widgets.add(
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(rowCells[i].columnTitle),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: customEditWidget,
                ),
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          EditRow(
            controller: controllers[i],
            columnName: rowCells[i].columnTitle,
            valueType: cellValue?.runtimeType ?? col?.type ?? dynamic,
            isEditable: col?.isEditable ?? true,
            hintText: col?.hintText,
            baseDecoration: theme.editInputDecoration,
            imageProvider: cellValue is ImageProvider ? cellValue : null,
          ),
        );
      }
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

  /// When non-null, renders an image preview instead of a text input.
  final ImageProvider? imageProvider;

  const EditRow({
    super.key,
    required this.controller,
    required this.columnName,
    required this.valueType,
    this.isEditable = true,
    this.hintText,
    this.baseDecoration,
    this.imageProvider,
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
            child: widget.imageProvider != null
                ? _buildImagePreview(widget.imageProvider!)
                : widget.valueType == bool
                    ? _buildBoolInput(widget.controller)
                    : _buildTextInput(widget.controller),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(ImageProvider provider) {
    return SizedBox(
      height: context.expandableTheme.imageColumnHeightExpansion ??
          GeneralConstants.imageColumnHeightExpansion,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image(
          image: provider,
          fit: BoxFit.contain,
        ),
      ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Switch(
        value: controller.text == 'true',
        onChanged: widget.isEditable
            ? (bool newValue) {
                setState(() {
                  controller.text = newValue.toString();
                });
              }
            : null,
      ),
    );
  }
}
