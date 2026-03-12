import 'package:expandable_datatable/src/utility/expandable_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpandableTheme.of', () {
    testWidgets(
        'returns the ancestor theme data when an ExpandableTheme is present',
        (tester) async {
      const data = ExpandableThemeData(headerHeight: 56);
      ExpandableThemeData? result;

      await tester.pumpWidget(
        MaterialApp(
          home: ExpandableTheme(
            data: data,
            child: Builder(
              builder: (context) {
                result = ExpandableTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(result?.headerHeight, 56);
    });

    testWidgets(
        'falls back to a default ExpandableThemeData when no ancestor is present',
        (tester) async {
      ExpandableThemeData? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = ExpandableTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(result, isNotNull);
      expect(result!.headerHeight, isNull);
      expect(result!.rowHeight, isNull);
    });
  });

  group('ExpandableTheme.updateShouldNotify', () {
    testWidgets(
        'notifies dependents and triggers a rebuild when theme data changes',
        (tester) async {
      int buildCount = 0;
      const dataA = ExpandableThemeData(headerHeight: 40);
      const dataB = ExpandableThemeData(headerHeight: 80);
      ExpandableThemeData? capturedData;

      final key = GlobalKey<_ControllableThemeState>();

      await tester.pumpWidget(
        _ControllableTheme(
          key: key,
          initialData: dataA,
          child: Builder(
            builder: (context) {
              capturedData = ExpandableTheme.of(context);
              buildCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(capturedData?.headerHeight, 40);

      key.currentState!.updateData(dataB);
      await tester.pump();

      expect(buildCount, 2);
      expect(capturedData?.headerHeight, 80);
    });

    testWidgets(
        'does not notify dependents or trigger a rebuild when theme data is identical',
        (tester) async {
      int buildCount = 0;
      const data = ExpandableThemeData(headerHeight: 40);

      final key = GlobalKey<_ControllableThemeState>();

      await tester.pumpWidget(
        _ControllableTheme(
          key: key,
          initialData: data,
          child: Builder(
            builder: (context) {
              ExpandableTheme.of(context);
              buildCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      key.currentState!.updateData(data);
      await tester.pump();

      expect(buildCount, 1);
    });
  });
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

/// A stateful wrapper that lets tests swap [ExpandableThemeData] at runtime to
/// exercise [ExpandableTheme.updateShouldNotify].
class _ControllableTheme extends StatefulWidget {
  final ExpandableThemeData initialData;
  final Widget child;

  const _ControllableTheme({
    super.key,
    required this.initialData,
    required this.child,
  });

  @override
  State<_ControllableTheme> createState() => _ControllableThemeState();
}

class _ControllableThemeState extends State<_ControllableTheme> {
  late ExpandableThemeData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  void updateData(ExpandableThemeData newData) {
    setState(() => _data = newData);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpandableTheme(
        data: _data,
        child: widget.child,
      ),
    );
  }
}
