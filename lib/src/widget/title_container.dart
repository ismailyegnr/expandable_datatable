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
    return Padding(
      padding: const EdgeInsets.only(
        right: GeneralConstants.titlePadding,
      ),
      child: element.cellBuilder != null
          ? element.cellBuilder!(context, element.value)
          : element.value is ImageProvider
              ? SizedBox(
                  height: context.expandableTheme.imageColumnHeightTitle ??
                      GeneralConstants.imageColumnHeightTitle,
                  child: Image(
                    image: element.value as ImageProvider,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
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
                )
              : Text(
                  element.value.toString(),
                  style: context.expandableTheme.rowTextStyle ??
                      Theme.of(context).textTheme.bodyMedium,
                  maxLines: context.expandableTheme.rowTextMaxLines ?? 3,
                  overflow: context.expandableTheme.rowTextOverflow ??
                      TextOverflow.ellipsis,
                ),
    );
  }
}
