import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../model/cell_item.dart';
import '../model/expandable_cell.dart';

class RowContainer extends StatelessWidget {
  final List<CellData> shownCells;

  const RowContainer({super.key, required this.shownCells});

  @override
  Widget build(BuildContext context) {
    var list = shownCells
        .map(
          (element) => Expanded(
            flex: element.column.flex,
            child: _buildCell(context, element.cell),
          ),
        )
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.lowValue),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  Padding _buildCell(BuildContext context, ExpandableCell cell) {
    return Padding(
      padding: const EdgeInsets.only(
        right: GeneralConstants.titlePadding,
      ),
      child: cell.render(),
    );
  }
}
