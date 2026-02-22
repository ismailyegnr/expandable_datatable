class ExpandableColumn<T> {
  String columnTitle;
  int columnFlex;

  /// Whether this column's field is editable in the default [EditDialog].
  ///
  /// When set to false, the corresponding input field is disabled and the
  /// original cell value is preserved unchanged after saving.
  ///
  /// Defaults to true.
  final bool isEditable;

  /// Optional hint text displayed inside this column's input field in the
  /// default [EditDialog].
  final String? hintText;

  Type get type => T;

  ExpandableColumn({
    required this.columnTitle,
    required this.columnFlex,
    this.isEditable = true,
    this.hintText,
  });
}
