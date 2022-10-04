import 'package:flutter/material.dart';

import '../extension/context_extension.dart';
import '../utility/expandable_theme_data.dart';

class PaginationWidget extends StatefulWidget {
  final int currentPage;
  final int totalPageCount;
  final ValueChanged onChanged;
  final int maxVisiblePage;

  const PaginationWidget({
    Key? key,
    required this.totalPageCount,
    required this.onChanged,
    required this.currentPage,
    this.maxVisiblePage = 4,
  }) : super(key: key);

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  /// The state of each [ToggleButton] button is controlled by this list.
  List<bool> _toggleButtons = [];

  /// Toggle buttons' mid point is stored for changing and showing the pages.
  int? _midPoint;

  late int _totalPageCount;

  @override
  void didUpdateWidget(covariant PaginationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentPage != oldWidget.currentPage) {
      setState(() {
        _changeMidPoint(widget.currentPage);

        _setButtons(widget.currentPage);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _totalPageCount = widget.totalPageCount;

    if (_totalPageCount == 0) {
      _toggleButtons = [];
    } else if (_totalPageCount == 1) {
      /// The total number of pages is 1, there is no need to have previous and
      /// next buttons.
      _toggleButtons = [true];
    } else if (_totalPageCount <= widget.maxVisiblePage) {
      /// Total page count is smaller than or equal to wanted shown page count. So,
      /// all pages will have their own buttons and previous and next buttons will
      /// be shown.
      _toggleButtons = List.filled(_totalPageCount + 2, false);

      /// First page is selected initially.
      _toggleButtons[1] = true;
    } else {
      /// Total page count is greater than the wanted shown page count. So, it needs
      /// to have a dynamic button appearances.
      _toggleButtons = List.filled(widget.maxVisiblePage + 2, false);

      /// Middle point is equal to integer division of the wanted shown page count.
      _midPoint = midPointMargin;

      /// First page is selected initially.
      _toggleButtons[1] = true;
    }
  }

  int get midPointMargin => widget.maxVisiblePage ~/ 2;

  /// Gives the previous button's index in the [_toggleButtons] list.
  int get prevButton => 0;

  /// Gives the next button's index in the [_toggleButtons] list.
  int get nextButton => _toggleButtons.length - 1;

  /// Switches the page value by tapped button index. If [_midPoint] is set, it
  /// is also changed.
  int _switchPage(int index) {
    int newPage = widget.currentPage;

    /// Next or Previous buttons are tapped.
    if (index == prevButton) {
      if (newPage != 0) {
        --newPage;
      }
    } else if (index == nextButton) {
      if (newPage < _totalPageCount - 1) {
        ++newPage;
      }
    } else {
      /// Page is changed by tapping page number.
      if (_midPoint == null) {
        newPage = index - 1;
      } else {
        newPage = _midPoint! + (index - (midPointMargin + 1));
      }
    }

    return newPage;
  }

  /// Set new midPoint according to new page value, if midPoint is set.
  void _changeMidPoint(int newPage) {
    if (_midPoint != null) {
      if (newPage < midPointMargin) {
        /// New page is closer to right edge. Gives least value of midPoint.
        _midPoint = midPointMargin;
      } else if (newPage >
          _totalPageCount - widget.maxVisiblePage + midPointMargin) {
        /// New page is closer to left(greatest) edge. Gives greates value of
        /// midPoint.
        _midPoint = _totalPageCount - widget.maxVisiblePage + midPointMargin;
      } else {
        /// New page is at the middle. midPoint and newPage is equal.
        _midPoint = newPage;
      }
    }
  }

  /// Sets the [_toggleButtons] list to change the state of the toggle buttons.
  void _setButtons(int newPage) {
    if (_midPoint == null) {
      for (int i = 0; i < _toggleButtons.length; i++) {
        bool state = i == newPage + 1;

        _toggleButtons[i] = state;
      }
    } else {
      int toggleIndex = (midPointMargin + 1) + (newPage - _midPoint!);
      for (int i = 0; i < _toggleButtons.length; i++) {
        bool state = i == toggleIndex;

        _toggleButtons[i] = state;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ExpandableThemeData theme = context.expandableTheme;
    final double size = theme.paginationSize;

    return ToggleButtons(
      constraints: BoxConstraints(minHeight: size, minWidth: size),
      textStyle: theme.paginationTextStyle,
      selectedColor: theme.paginationSelectedTextColor,
      color: theme.paginationUnselectedTextColor,
      fillColor: theme.paginationSelectedFillColor,
      borderColor: theme.paginationBorderColor,
      borderRadius: theme.paginationBorderRadius,
      borderWidth: theme.paginationBorderWidth,
      selectedBorderColor: theme.paginationBorderColor,
      isSelected: _toggleButtons,
      onPressed: (int index) {
        int oldPage = widget.currentPage;

        int newPage = _switchPage(index);

        if (newPage != oldPage) {
          widget.onChanged(newPage);
        }
      },
      children: buildButtons(),
    );
  }

  List<Widget> buildButtons() {
    if (_totalPageCount == 0) {
      return [];
    } else if (_totalPageCount == 1) {
      return [const Text("0")];
    }

    return [
      const Icon(Icons.keyboard_arrow_left),
      ...List.generate(
        _totalPageCount > widget.maxVisiblePage
            ? widget.maxVisiblePage
            : _totalPageCount,
        (index) => _midPoint == null
            ? Text("$index")
            : Text("${_midPoint! + index - midPointMargin}"),
      ),
      const Icon(Icons.keyboard_arrow_right),
    ];
  }
}
