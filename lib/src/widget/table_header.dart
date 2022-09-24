import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../extension/context_extension.dart';
import '../model/expandable_column.dart';
import '../utility/sort_information.dart';

class TableHeader extends StatelessWidget {
  final SortInformation currentSort;
  final List<ExpandableColumn<dynamic>> headerRow;
  final Function(ExpandableColumn<dynamic>) onTitleTap;

  final double trailingWidth;

  const TableHeader({
    Key? key,
    required this.headerRow,
    required this.currentSort,
    required this.onTitleTap,
    required this.trailingWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var boxDecoration = BoxDecoration(
      border: Border(
        bottom: context.expandableTheme.headerBorder,
      ),
      color: context.expandableTheme.headerColor,
    );

    return Container(
      decoration: boxDecoration,
      height: context.expandableTheme.headerHeight,
      child: Center(
        child: ListTile(
          dense: true,
          title: IntrinsicHeight(
            child: Row(
              children: headerRow
                  .map(
                    (e) => Expanded(
                      flex: e.columnFlex,
                      child: SizedBox.expand(
                        child: buildHeaderTitle(context, e),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          trailing: SizedBox(
            width: trailingWidth,
          ),
        ),
      ),
    );
  }

  GestureDetector buildHeaderTitle(
      BuildContext context, ExpandableColumn<dynamic> column) {
    Color? iconColor = context.expandableTheme.headerSortIconColor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTitleTap(column),
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.lowValue).copyWith(
            right: GeneralConstants.titlePadding,
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  column.columnTitle,
                  style: context.expandableTheme.headerTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: context.expandableTheme.headerTextMaxLines,
                ),
              ),
              Visibility(
                visible: currentSort.sortedColumn != null &&
                    currentSort.sortedColumn == column,
                child: currentSort.sortOption == SortOption.ASC
                    ? Icon(
                        Icons.arrow_drop_up,
                        color: iconColor,
                      )
                    : Icon(
                        Icons.arrow_drop_down,
                        color: iconColor,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
