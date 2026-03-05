import 'package:flutter/material.dart';

import '../constants/constants.dart';
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
            var edgeInsets = context.expandableTheme.expansionCellPadding ??
                EdgeInsets.symmetric(
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
    final expandedTextStyle = context.expandableTheme.expandedTextStyle ??
        Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "${element.columnName}:",
            style: expandedTextStyle,
          ),
        ),
        Expanded(
          flex: 4,
          child: element.value is ImageProvider
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: GeneralConstants.imageColumnHeightExpansion,
                    child: Image(
                      image: element.value as ImageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Text(
                  "${element.value}",
                  style: expandedTextStyle,
                ),
        ),
      ],
    );
  }
}
