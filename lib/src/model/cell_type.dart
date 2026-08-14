import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../extension/context_extension.dart';

/// Abstract adapter that encapsulates rendering, editing, sorting, and string
/// conversion for a specific data type [T].
abstract class CellType<T> {
  const CellType();

  /// Builds the widget to render in the visible title row.
  Widget buildTitleCell(
    BuildContext context,
    T? value,
    TextStyle? textStyle,
  );

  /// Builds the widget to render in the expanded details row.
  Widget buildExpansionCell(
    BuildContext context,
    T? value,
    TextStyle? textStyle,
  );

  /// Builds an edit widget for [EditDialog].
  ///
  /// Return `null` to use the default text input field.
  Widget? buildEditField(
    BuildContext context,
    T? value,
    ValueChanged<T?> onChanged, {
    bool isEditable = true,
    String? hintText,
    InputDecoration? baseDecoration,
  }) =>
      null;

  /// Compares two cell values for table sorting.
  ///
  /// Returns a negative integer if [a] should sort before [b], a positive
  /// integer if [a] should sort after [b], and 0 if they are considered equal
  /// or if this type is not sortable.
  int compare(T? a, T? b);

  /// Returns a string representation of [value] or [placeholder] if null.
  String toDisplayString(T? value, String placeholder) {
    return value != null ? value.toString() : placeholder;
  }
}

/// Built-in [CellType] for [String] values.
class StringCellType extends CellType<String> {
  const StringCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    String? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.rowTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
      maxLines: context.expandableTheme.rowTextMaxLines ?? 3,
      overflow:
          context.expandableTheme.rowTextOverflow ?? TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    String? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.expandedTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  int compare(String? a, String? b) {
    final aVal = a?.toLowerCase() ?? '';
    final bVal = b?.toLowerCase() ?? '';
    return aVal.compareTo(bVal);
  }
}

/// Built-in [CellType] for numeric values ([int], [double], [num]).
class NumericCellType<T extends num> extends CellType<T> {
  const NumericCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    T? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.rowTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
      maxLines: context.expandableTheme.rowTextMaxLines ?? 3,
      overflow:
          context.expandableTheme.rowTextOverflow ?? TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    T? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.expandedTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  int compare(T? a, T? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }
}

/// Built-in [CellType] for boolean values.
class BoolCellType extends CellType<bool> {
  const BoolCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    bool? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.rowTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
      maxLines: context.expandableTheme.rowTextMaxLines ?? 3,
      overflow:
          context.expandableTheme.rowTextOverflow ?? TextOverflow.ellipsis,
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    bool? value,
    TextStyle? textStyle,
  ) {
    return Text(
      toDisplayString(value, ''),
      style: textStyle ??
          context.expandableTheme.expandedTextStyle ??
          Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  Widget? buildEditField(
    BuildContext context,
    bool? value,
    ValueChanged<bool?> onChanged, {
    bool isEditable = true,
    String? hintText,
    InputDecoration? baseDecoration,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Switch(
        value: value ?? false,
        onChanged: isEditable ? (bool newValue) => onChanged(newValue) : null,
      ),
    );
  }

  @override
  int compare(bool? a, bool? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return (a ? 1 : 0).compareTo(b ? 1 : 0);
  }
}

/// Built-in [CellType] for [ImageProvider] values with declarative styling.
class ImageCellType extends CellType<ImageProvider> {
  /// Custom image height override.
  final double? height;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  /// How to align the image within its bounds.
  final Alignment alignment;

  /// Optional border radius to clip the image.
  final BorderRadius? borderRadius;

  /// Optional custom builder callback.
  final Widget Function(BuildContext context, ImageProvider image)?
      customBuilder;

  const ImageCellType({
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    this.borderRadius,
    this.customBuilder,
  });

  Widget _buildImageWidget(
    BuildContext context,
    ImageProvider? value, {
    TextStyle? fallbackTextStyle,
    required double defaultHeight,
    bool isEditField = false,
  }) {
    if (value == null) {
      if (isEditField) return const SizedBox.shrink();
      return Text(
        '',
        style: fallbackTextStyle ?? Theme.of(context).textTheme.bodyMedium,
      );
    }

    if (!isEditField && customBuilder != null) {
      return customBuilder!(context, value);
    }

    final double effectiveHeight = height ?? defaultHeight;

    Widget imageWidget = SizedBox(
      height: effectiveHeight,
      child: Image(
        image: value,
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
        fit: fit,
        alignment: alignment,
      ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  @override
  Widget buildTitleCell(
    BuildContext context,
    ImageProvider? value,
    TextStyle? textStyle,
  ) {
    return _buildImageWidget(
      context,
      value,
      fallbackTextStyle: textStyle ?? context.expandableTheme.rowTextStyle,
      defaultHeight: context.expandableTheme.imageColumnHeightTitle ??
          GeneralConstants.imageColumnHeightTitle,
    );
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    ImageProvider? value,
    TextStyle? textStyle,
  ) {
    return _buildImageWidget(
      context,
      value,
      fallbackTextStyle: textStyle ?? context.expandableTheme.expandedTextStyle,
      defaultHeight: context.expandableTheme.imageColumnHeightExpansion ??
          GeneralConstants.imageColumnHeightExpansion,
    );
  }

  @override
  Widget? buildEditField(
    BuildContext context,
    ImageProvider? value,
    ValueChanged<ImageProvider?> onChanged, {
    bool isEditable = true,
    String? hintText,
    InputDecoration? baseDecoration,
  }) {
    return _buildImageWidget(
      context,
      value,
      defaultHeight: context.expandableTheme.imageColumnHeightExpansion ??
          GeneralConstants.imageColumnHeightExpansion,
      isEditField: true,
    );
  }

  @override
  int compare(ImageProvider? a, ImageProvider? b) => 0;

  @override
  String toDisplayString(ImageProvider? value, String placeholder) =>
      placeholder;
}
