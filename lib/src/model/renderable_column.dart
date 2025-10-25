import 'package:flutter/material.dart';
import '../../expandable_datatable.dart';

class RenderableColumn extends ExpandableColumn {
  RenderableColumn({
    required super.title,
    required super.accessor,
  });

  Widget render() {
    return Container();
  }
}
