import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../extension/context_extension.dart';
import '../model/expandable_column.dart';
import '../utility/sort_information.dart';

class TableHeader extends StatelessWidget {
  final SortInformation currentSort;
  final List<ExpandableColumn<dynamic>> headerRow;
  final Function(ExpandableColumn<dynamic>) onTitleTap;

  /// Whether the table rows have an edit icon in the trailing area.
  final bool isEditable;

  /// Whether the expansion icon is shown on the leading side of each row.
  ///
  /// When true, an invisible leading ghost icon is inserted to keep header
  /// columns aligned with row content.
  final bool isLeadingExpansion;

  const TableHeader({
    super.key,
    required this.headerRow,
    required this.currentSort,
    required this.onTitleTap,
    required this.isEditable,
    required this.isLeadingExpansion,
  });

  double _resolveIconSize(Widget? icon, {required double fallback}) {
    return icon is Icon ? (icon.size ?? fallback) : fallback;
  }

  /// Returns the effective width of an [IconButton] with [padding: EdgeInsets.zero].
  ///
  /// Flutter clamps the touch target to at least [kMinInteractiveDimension]
  /// (adjusted by [VisualDensity]), or the raw icon size – whichever is larger.
  double _iconButtonWidth(BuildContext context, {required double iconSize}) {
    final double densityAdjustment =
        Theme.of(context).visualDensity.baseSizeAdjustment.dx;
    return max(kMinInteractiveDimension + densityAdjustment, iconSize);
  }

  /// Builds an invisible placeholder matching the leading expansion icon so
  /// header columns stay aligned with row content.
  Widget _buildLeadingGhost(BuildContext context) {
    final double iconSize = _resolveIconSize(
      context.expandableTheme.expansionIcon,
      fallback: GeneralConstants.defaultExpansionIconSize,
    );

    return SizedBox(width: iconSize + GeneralConstants.leadingRightPadding);
  }

  /// Builds an invisible placeholder matching the trailing icons (edit and/or
  /// expansion) so header columns stay aligned with row content.
  Widget _buildTrailingGhost(BuildContext context) {
    final theme = context.expandableTheme;

    final double editButtonWidth = _iconButtonWidth(
      context,
      iconSize: _resolveIconSize(theme.editIcon,
          fallback: GeneralConstants.defaultEditIconSize),
    );

    final double expansionIconWidth = _resolveIconSize(
      theme.expansionIcon,
      fallback: GeneralConstants.defaultExpansionIconSize,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEditable) SizedBox(width: editButtonWidth),
        if (!isLeadingExpansion) SizedBox(width: expansionIconWidth),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var boxDecoration = BoxDecoration(
      border: Border(
        bottom: context.expandableTheme.headerBorder ??
            const BorderSide(
              width: 2.5,
              color: Color(0xffeeeeee),
            ),
      ),
      color: context.expandableTheme.headerColor ??
          Theme.of(context).colorScheme.surface,
    );

    double? height = context.expandableTheme.headerHeight;
    late EdgeInsets padding;
    final themeContentPadding =
        context.expandableTheme.contentPadding ?? const EdgeInsets.all(16.0);

    if (height == null) {
      padding = themeContentPadding;
    } else {
      padding = EdgeInsets.only(
        right: themeContentPadding.right,
        left: themeContentPadding.left,
      );
    }

    return Container(
      decoration: boxDecoration,
      padding: padding,
      height: height,
      child: Row(children: [
        if (isLeadingExpansion) _buildLeadingGhost(context),
        ...headerRow.map(
          (e) => Expanded(
            flex: e.columnFlex,
            child: buildHeaderTitle(context, e),
          ),
        ),
        if (isEditable || !isLeadingExpansion) _buildTrailingGhost(context),
      ]),
    );
  }

  GestureDetector buildHeaderTitle(
      BuildContext context, ExpandableColumn<dynamic> column) {
    final ThemeData theme = Theme.of(context);
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
                  style: context.expandableTheme.headerTextStyle ??
                      theme.textTheme.titleMedium,
                  overflow: context.expandableTheme.rowTextOverflow ??
                      TextOverflow.ellipsis,
                  maxLines: context.expandableTheme.headerTextMaxLines ?? 2,
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
