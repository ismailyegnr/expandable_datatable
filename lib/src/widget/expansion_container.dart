import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../model/cell_item.dart';

class ExpansionContainer extends StatelessWidget {
  final List<CellItem> expansionCells;

  const ExpansionContainer({
    super.key,
    required this.expansionCells,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...expansionCells.map(
          (element) {
            var edgeInsets = EdgeInsets.symmetric(
              horizontal: context.normalValue,
              vertical: context.lowValue,
            );

            return Padding(
              padding: edgeInsets,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildRow(element, context),
              ),
            );
          },
        ),
      ],
    );
  }

  Row _buildRow(CellItem element, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "${element.columnName}:",
            style: context.expandableTheme.expandedTextStyle,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            "${element.value}",
            style: context.expandableTheme.expandedTextStyle,
          ),
        ),
      ],
    );
  }
}
