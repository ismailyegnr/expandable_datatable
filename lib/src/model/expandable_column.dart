abstract class AbstractColumn {
  final String title;
  final String accessor;
  int flex;

  AbstractColumn({
    required this.title,
    required this.accessor,
    this.flex = 1,
  });
}

// TODO:: Add visible or not feature
class ExpandableColumn extends AbstractColumn {
  final bool sortable;
  final bool editable;

  ExpandableColumn({
    required super.title,
    required super.accessor,
    super.flex,
    this.sortable = true,
    this.editable = true,
  });
}
