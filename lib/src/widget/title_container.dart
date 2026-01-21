import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../extension/context_extension.dart';
import '../model/cell_item.dart';

class TitleContainer extends StatelessWidget {
  final List<CellItem> titleCells;

  const TitleContainer({super.key, required this.titleCells});

  @override
  Widget build(BuildContext context) {
    var edgeInsets = EdgeInsets.symmetric(vertical: context.lowValue);

    return Padding(
      padding: edgeInsets,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: titleCells
            .map(
              (element) => Expanded(
                flex: element.flex!,
                child: _buildCell(context, element),
              ),
            )
            .toList(),
      ),
    );
  }

  Padding _buildCell(BuildContext context, CellItem element) {
    return Padding(
      padding: const EdgeInsets.only(
        right: GeneralConstants.titlePadding,
      ),
      child: Text(
        element.value.toString(),
        style: context.expandableTheme.rowTextStyle,
        maxLines: context.expandableTheme.rowTextMaxLines,
        overflow: context.expandableTheme.rowTextOverflow,
      ),
    );
  }
}
