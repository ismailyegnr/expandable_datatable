import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../exception/no_support_exception.dart';
import '../extension/string_extension.dart';
import '../model/expandable_row.dart';

class EditDialog extends StatefulWidget {
  final ExpandableRow row;
  final Function(ExpandableRow newRow) onSuccess;

  const EditDialog({
    super.key,
    required this.row,
    required this.onSuccess,
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

  void _processCellUpdate() {
    if (_formKey.currentState!.validate()) {
      List<ExpandableCell> resultCellList = [];

      for (int i = 0; i < rowCells.length; i++) {
        ExpandableCell oldCell = rowCells[i];

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

      ExpandableRow result = ExpandableRow(
        cells: resultCellList,
      );

      widget.onSuccess(result);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Edit Details'),
      actions: buildActionButtons(),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: buildAlertDialogContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildActionButtons() {
    return <Widget>[
      TextButton(
        onPressed: () => _processCellUpdate(),
        child: const Text(
          'SAVE',
          style: TextStyle(color: Colors.cyan),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'CANCEL',
          style: TextStyle(color: Colors.cyan),
        ),
      ),
    ];
  }

  Widget buildAlertDialogContent() {
    List<Widget> widgets = [];

    for (int i = 0; i < rowCells.length; i++) {
      widgets.add(
        EditRow(
          controller: controllers[i],
          columnName: rowCells[i].columnTitle,
          valueType: rowCells[i].value.runtimeType,
        ),
      );
    }

    return Column(
      children: widgets,
    );
  }
}

class EditRow extends StatefulWidget {
  final TextEditingController controller;
  final String columnName;
  final Type valueType;

  const EditRow(
      {super.key,
      required this.controller,
      required this.columnName,
      required this.valueType});

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
                ? buildBoolInput(widget.controller)
                : buildTextInput(
                    widget.controller,
                  ),
          ),
        )
      ],
    );
  }

  Widget buildTextInput(TextEditingController controller) {
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
      enabled: widget.columnName != "ID",
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Field must not be empty';
        }
        return null;
      },
      controller: controller,
    );
  }

  Widget buildBoolInput(TextEditingController controller) {
    String dropdownVal = controller.text;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: dropdownVal,
        onChanged: (String? newValue) {
          setState(() {
            controller.text = newValue!;
            dropdownVal = controller.text;
          });
        },
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
