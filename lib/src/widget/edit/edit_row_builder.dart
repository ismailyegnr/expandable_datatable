import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../model/expandable_cell.dart';
import '../../model/expandable_column.dart';
import '../button/edit_switch.dart';
import '../form_field/edit_form_field.dart';

abstract class ExpandableCellWidget extends StatelessWidget {
  final ExpandableColumn header;
  final ExpandableCell cell;

  const ExpandableCellWidget({
    super.key,
    required this.header,
    required this.cell,
  });

  @override
  Widget build(BuildContext context);
}

class StringCellEditWidget extends ExpandableCellWidget {
  const StringCellEditWidget({
    super.key,
    required super.header,
    required super.cell,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header.title),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: EditFormField(
              enabled: header.editable,
              initialValue: cell.value,
              onChanged: (p0) {
                cell.value = p0;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NumberCellEditWidget extends ExpandableCellWidget {
  const NumberCellEditWidget(
      {super.key, required super.header, required super.cell});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header.title),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: EditFormField(
              enabled: header.editable,
              initialValue: cell.value.toString(),
              onChanged: (p0) {
                cell.value = p0;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BooleanCellEditWidget extends ExpandableCellWidget {
  const BooleanCellEditWidget(
      {super.key, required super.header, required super.cell});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: EditSwitch(),
        ),
        Expanded(
          flex: GeneralConstants.editTitleFlex,
          child: Text(header.title),
        )
      ],
    );
  }
}
