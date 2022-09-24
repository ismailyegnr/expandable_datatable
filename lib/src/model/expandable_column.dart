class ExpandableColumn<T> {
  String columnTitle;
  int columnFlex;

  Type get type => T;

  ExpandableColumn({
    required this.columnTitle,
    required this.columnFlex,
  });
}
