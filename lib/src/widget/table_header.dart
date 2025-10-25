import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../model/expandable_column.dart';
import '../utility/sort_utility.dart';

class TableHeader extends StatelessWidget {
  final SortUtil sortData;
  final List<ExpandableColumn> headers;
  final Function(ExpandableColumn) onHeaderTap;
  final double trailingWidth;

  const TableHeader({
    Key? key,
    required this.sortData,
    required this.headers,
    required this.onHeaderTap,
    required this.trailingWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? height = context.expandableTheme.headerHeight;
    late EdgeInsets padding;

    padding = EdgeInsets.only(
      right: context.expandableTheme.contentPadding.right,
      left: context.expandableTheme.contentPadding.left,
    );
  
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: context.expandableTheme.headerBorder,
        ),
        color: context.expandableTheme.headerColor,
      ),
      height: height,
      child: _buildHeaders(padding, context),
    );
  }

  Widget _buildHeaders(EdgeInsets padding, BuildContext context) {
    var row = Row(
        children: headers
            .map(
              (item) => Expanded(
                flex: item.flex,
                child: SizedBox.expand(
                  child: _buildOneTitle(
                    context,
                    item,
                  ),
                ),
              ),
            )
            .toList());

    return Center(
      child: ListTile(
        contentPadding: padding,
        dense: true,
        title: IntrinsicHeight(
          child: row,
        ),
        trailing: SizedBox(
          width: trailingWidth,
        ),
      ),
    );
  }

  Widget _buildOneTitle(BuildContext context, ExpandableColumn column) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: column.sortable ? () => onHeaderTap(column) : null,
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.lowValue).copyWith(
            right: GeneralConstants.titlePadding,
          ),
          child: Row(
            children: [
              _buildText(context, column),
              _buildSortIcon(context, column),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, ExpandableColumn column) {
    return Flexible(
      child: Text(
        column.title,
        style: context.expandableTheme.headerTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: context.expandableTheme.headerTextMaxLines,
      ),
    );
  }

  Widget _buildSortIcon(BuildContext context, ExpandableColumn column) {
    return Visibility(
      visible: sortData.sortType != SortType.ORIGINAL &&
          sortData.sortedAccessor == column.accessor,
      child: sortData.sortType == SortType.ASC
          ? Icon(
              Icons.arrow_drop_up,
              color: context.expandableTheme.headerSortIconColor,
            )
          : Icon(
              Icons.arrow_drop_down,
              color: context.expandableTheme.headerSortIconColor,
            ),
    );
  }
}
