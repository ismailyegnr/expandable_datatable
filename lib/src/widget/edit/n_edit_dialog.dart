import 'package:flutter/material.dart';

import '../../../expandable_datatable.dart';
import 'edit_row_builder.dart';

class NEditDialog extends StatefulWidget {
  final List<ExpandableColumn> headers;
  final ExpandableRow row;
  final void Function(List<ExpandableCell> cells) onSaved;

  const NEditDialog({
    Key? key,
    required this.headers,
    required this.row,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<NEditDialog> createState() => _NEditDialogState();
}

class _NEditDialogState extends State<NEditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<ExpandableCell> copyCellList;

  @override
  void initState() {
    super.initState();

    copyCellList = widget.row.cells;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: buildRowForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.2, color: Colors.grey),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close)),
                ),
                const Text(
                  "Edit",
                  style: TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRowForm() {
    List<Widget> column = [];

    for (ExpandableCell cell in copyCellList) {
      ExpandableColumn cellHeader = widget.headers
          .firstWhere((element) => element.accessor == cell.accessor);

      if (cell is StringCell) {
        column.add(StringCellEditWidget(header: cellHeader, cell: cell));
      } else if (cell is NumberCell) {
        column.add(NumberCellEditWidget(header: cellHeader, cell: cell));
      } else if (cell is BooleanCell) {
        column.add(BooleanCellEditWidget(header: cellHeader, cell: cell));
      } else {
        return const SizedBox.shrink();
      }
    }

    return Column(
      children: [
        ...column,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSaved(copyCellList);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Save"),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Cancel"),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
