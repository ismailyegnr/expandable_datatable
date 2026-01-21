class ExpandableRow {
  final List<ExpandableCell> cells;
  ExpandableRow({
    required this.cells,
  });
}

class ExpandableCell<T> {
  final String columnTitle;
  T? value;

  ExpandableCell({
    required this.columnTitle,
    this.value,
  });
}
