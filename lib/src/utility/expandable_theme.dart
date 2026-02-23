import 'package:flutter/material.dart';

class ExpandableTheme extends InheritedWidget {
  final ExpandableThemeData data;

  const ExpandableTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static ExpandableThemeData of(BuildContext context) {
    final ExpandableTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<ExpandableTheme>();
    // If no ExpandableTheme is found, fallback to a static default
    return inheritedTheme?.data ?? const ExpandableThemeData();
  }

  @override
  bool updateShouldNotify(ExpandableTheme oldWidget) => data != oldWidget.data;
}

class ExpandableThemeData {
  /// Specifies padding for all header and data rows.
  ///
  /// If [headerHeight] is already specified, this will only affect the header row
  /// horizontally.
  ///
  /// It defaults to `EdgeInsets.all(16.0)`.
  final EdgeInsets? contentPadding;

  /// Text style of header row.
  ///
  /// If null, the theme's [TextTheme.titleMedium] is used.
  final TextStyle? headerTextStyle;

  /// Text style of all rows.
  ///
  /// If null, the theme's [TextTheme.bodyMedium] is used.
  final TextStyle? rowTextStyle;

  /// Maximum number of lines for header text to span.
  ///
  /// If null, defaults to 2.
  final int? headerTextMaxLines;

  /// Maximum number of lines for row text to span.
  ///
  /// If null, defaults to 3.
  final int? rowTextMaxLines;

  /// Visual overflow of the row's cell text.
  ///
  /// If null, defaults to [TextOverflow.ellipsis].
  final TextOverflow? rowTextOverflow;

  /// Text style of expansion content.
  ///
  /// If null, the theme's [TextTheme.bodyMedium] is used.
  final TextStyle? expandedTextStyle;

  /// Background color of header row.
  ///
  /// If null, the theme's [ColorScheme.surface] is used.
  final Color? headerColor;

  /// Color of the header sort arrow icon.
  final Color? headerSortIconColor;

  /// Height of the header widget.
  final double? headerHeight;

  /// Background color of rows.
  ///
  /// If null, the theme's [ColorScheme.surface] is used.
  ///
  /// It is used only if [evenRowColor] and [oddRowColor] are null.
  final Color? rowColor;

  /// Background color of the even indexed rows.
  ///
  /// It is used only if both [evenRowColor] and [oddRowColor] are not null.
  final Color? evenRowColor;

  /// Background color of the odd indexed rows.
  ///
  /// It is used only if both [evenRowColor] and [oddRowColor] are not null.
  final Color? oddRowColor;

  /// Background color applied to a row when its expandable content is visible.
  ///
  /// If this property is null, the row retains its current background color
  /// (either [rowColor], [evenRowColor], or [oddRowColor]) upon expansion.
  final Color? expandedBackgroundColor;

  /// Border style of header row.
  ///
  /// If this property is null, the following default border is used:
  ///
  /// ```dart
  /// const BorderSide(
  ///   width: 2.5,
  ///   color: Color(0xffeeeeee),
  /// )
  ///```
  final BorderSide? headerBorder;

  /// Border style of all rows.
  @Deprecated('Use shape instead')
  final BorderSide? rowBorder;

  /// Expansion border color.
  @Deprecated('Use expandedShape instead')
  final Color? expandedBorderColor;

  /// The rows' border shape when the expandable content is collapsed.
  ///
  /// If this property is null, a [Border] with vertical sides default to
  /// Color [Colors.transparent] is used.
  final ShapeBorder? shape;

  /// The rows' border shape when the expandable content is expanded.
  ///
  /// If this property is null, a [Border] with vertical sides default to
  /// [ThemeData.dividerColor] is used.
  final ShapeBorder? expandedShape;

  /// Icon image showing editing feature.
  ///
  /// If this property is null, the following default icon is used:
  ///
  /// ```dart
  /// Icon(
  ///   Icons.edit,
  ///   size: 16,
  /// )
  /// ```
  final Icon? editIcon;

  /// Icon image expanding expansion content.
  ///
  /// If this property is null, the following default icon is used:
  ///
  /// ```dart
  /// Icon(
  ///   Icons.expand_more,
  ///   size: 20,
  /// )
  /// ```
  final Icon? expansionIcon;

  /// Color of icons when the expandable content is collapsed.
  ///
  /// If null, the theme's [ColorScheme.onSurfaceVariant] is used.
  final Color? iconColor;

  /// Color of icons when the expandable content is expanded.
  ///
  /// If null, the theme's [ColorScheme.onSurface] is used.
  final Color? expandedIconColor;

  /// Expansion animation curve and duration.
  ///
  /// If [AnimationStyle.duration] is provided, it will be used to override
  /// the expansion animation duration, otherwise defaults to 200ms.
  ///
  /// If [AnimationStyle.curve] is provided, it will be used to override
  /// the expansion animation curve, otherwise defaults to [Curves.easeIn].
  ///
  /// If [AnimationStyle.reverseCurve] is provided, it will be used to override
  /// the collapse animation curve, otherwise the same curve will be used as for expansion.
  ///
  /// To disable the theme animation, use [AnimationStyle.noAnimation].
  final AnimationStyle? expansionAnimationStyle;

  /// Height of the rows
  final double? rowHeight;

  /// Padding for the children content inside an expanded row.
  ///
  /// If null, defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry? expansionChildrenPadding;

  /// Padding for individual cells in the expansion content container.
  ///
  /// If null, defaults to `EdgeInsets.symmetric(horizontal: 0.02 * screenHeight, vertical: 0.01 * screenHeight)`.
  final EdgeInsetsGeometry? expansionCellPadding;

  /// --------------------------------------------------------------------------
  /// Edit dialog properties
  /// --------------------------------------------------------------------------

  /// Text style of the edit dialog title.
  ///
  /// If null, the [AlertDialog] default title style is used.
  final TextStyle? editDialogTitleStyle;

  /// Background color of the edit dialog.
  ///
  /// If null, the theme's [DialogTheme.backgroundColor] is used.
  final Color? editDialogBackgroundColor;

  /// Shape of the edit dialog.
  ///
  /// If null, the theme's [DialogTheme.shape] is used.
  final ShapeBorder? editDialogShape;

  /// Text style of the SAVE button in the edit dialog.
  ///
  /// If null, defaults to `TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)`.
  final TextStyle? editSaveButtonTextStyle;

  /// Text style of the CANCEL button in the edit dialog.
  ///
  /// If null, defaults to `TextStyle(color: Colors.cyan)`.
  final TextStyle? editCancelButtonTextStyle;

  /// Base [InputDecoration] applied to every text field in the edit dialog.
  ///
  /// Per-column [ExpandableColumn.hintText] is merged on top via
  /// [InputDecoration.copyWith], so it always takes precedence over any
  /// [hintText] set here.
  final InputDecoration? editInputDecoration;

  /// --------------------------------------------------------------------------
  /// Pagination properties
  /// --------------------------------------------------------------------------

  /// Size of the default pagination widget.
  ///
  /// Default size is 48.0.
  final double? paginationSize;

  /// The [TextStyle] used for the page numbers (both selected and unselected).
  final TextStyle? paginationTextStyle;

  /// The color used for the text of the currently selected page number button.
  final Color? paginationSelectedTextColor;

  /// The color used for the text of the unselected page number buttons.
  final Color? paginationUnselectedTextColor;

  /// The fill color (background color) of the currently selected page number button.
  final Color? paginationSelectedFillColor;

  /// The border color applied to the page number buttons.
  final Color? paginationBorderColor;

  /// The radius applied to the corners of the page number buttons.
  final BorderRadius? paginationBorderRadius;

  /// The width of the border applied to the page number buttons.
  final double? paginationBorderWidth;

  const ExpandableThemeData({
    this.contentPadding,
    this.headerTextStyle,
    this.rowTextStyle,
    this.headerTextMaxLines,
    this.rowTextMaxLines,
    this.rowTextOverflow,
    this.expandedTextStyle,
    this.headerColor,
    this.headerSortIconColor,
    this.headerHeight,
    this.rowColor,
    this.evenRowColor,
    this.oddRowColor,
    this.expandedBackgroundColor,
    this.headerBorder,
    @Deprecated('Use shape instead') this.rowBorder,
    @Deprecated('Use expandedShape instead') this.expandedBorderColor,
    this.shape,
    this.expandedShape,
    this.rowHeight,
    this.editIcon,
    this.expansionIcon,
    this.iconColor,
    this.expandedIconColor,
    this.expansionAnimationStyle,
    this.expansionChildrenPadding,
    this.expansionCellPadding,
    this.editDialogTitleStyle,
    this.editDialogBackgroundColor,
    this.editDialogShape,
    this.editSaveButtonTextStyle,
    this.editCancelButtonTextStyle,
    this.editInputDecoration,
    this.paginationSize,
    this.paginationTextStyle,
    this.paginationSelectedTextColor,
    this.paginationUnselectedTextColor,
    this.paginationSelectedFillColor,
    this.paginationBorderColor,
    this.paginationBorderRadius,
    this.paginationBorderWidth,
  });
}
