import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../extension/context_extension.dart';
import '../model/cell_item.dart';

class TitleContainer extends StatelessWidget {
  final List<CellItem> titleCells;

  const TitleContainer({super.key, required this.titleCells});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: titleCells
          .map(
            (element) => Expanded(
              flex: element.flex!,
              child: _buildCell(context, element),
            ),
          )
          .toList(),
    );
  }

  Padding _buildCell(BuildContext context, CellItem element) {
    final textStyle = context.expandableTheme.rowTextStyle ??
        Theme.of(context).textTheme.bodyMedium;

    Widget cellWidget;

    if (element.cellBuilder != null) {
      cellWidget = element.cellBuilder!(context, element.value);
    } else if (element.cellType != null) {
      cellWidget = element.cellType!.buildTitleCell(
        context,
        element.value,
        textStyle,
      );
    } else if (element.value is ImageProvider) {
      cellWidget = SizedBox(
        height: context.expandableTheme.imageColumnHeightTitle ??
            GeneralConstants.imageColumnHeightTitle,
        child: Image(
          image: element.value as ImageProvider,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 1),
              child: child,
            );
          },
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      );
    } else {
      cellWidget = Text(
        element.value != null
            ? element.value.toString()
            : (element.nullValuePlaceholder ?? ''),
        style: textStyle,
        maxLines: context.expandableTheme.rowTextMaxLines ?? 3,
        overflow: context.expandableTheme.rowTextOverflow ??
            TextOverflow.ellipsis,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        right: GeneralConstants.titlePadding,
      ),
      child: cellWidget,
    );
  }
}
