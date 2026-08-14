import 'dart:convert';

import 'package:example_datatable/model/models.dart';
import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Users> userList = [];

  late List<ExpandableRow> rows;

  bool _isLoading = true;

  void setLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetch();
  }

  void fetch() async {
    userList = await getUsers();

    createDataSource();

    setLoading();
  }

  Future<List<Users>> getUsers() async {
    final String response = await rootBundle.loadString("asset/dumb.json");

    final data = await json.decode(response);

    API apiData = API.fromJson(data);

    if (apiData.users != null) {
      return apiData.users!;
    } else {
      return [];
    }
  }

  void createDataSource() {
    rows = userList.map<ExpandableRow>((e) {
      return ExpandableRow(
        cells: [
          ExpandableCell<int>(columnTitle: "ID", value: e.id),
          ExpandableCell<ImageProvider>(
            columnTitle: "Picture",
            value: NetworkImage(e.image ?? ""),
          ),
          ExpandableCell<String>(columnTitle: "First name", value: e.firstName),
          ExpandableCell<String>(columnTitle: "Last name", value: e.lastName),
          ExpandableCell<DateTime>(
            columnTitle: "Birth Date",
            value: e.birthDate,
          ),
          ExpandableCell<int>(columnTitle: "Age", value: e.age),
          ExpandableCell<String>(columnTitle: "Email", value: e.email),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_isLoading
            ? LayoutBuilder(
                builder: (context, constraints) {
                  int visibleCount = 4;
                  if (constraints.maxWidth < 600) {
                    visibleCount = 4;
                  } else if (constraints.maxWidth < 800) {
                    visibleCount = 5;
                  } else if (constraints.maxWidth < 1000) {
                    visibleCount = 6;
                  } else {
                    visibleCount = 7;
                  }

                  return ExpandableTheme(
                    data: ExpandableThemeData(
                      contentPadding: const EdgeInsets.all(10),
                      headerHeight: 60,
                      headerTextMaxLines: 2,
                      rowTextMaxLines: 2,
                      rowTextOverflow: TextOverflow.ellipsis,
                      headerColor: Colors.amber[400],
                      headerSortIconColor: const Color(0xFF6c59cf),
                      evenRowColor: const Color(0xFFFFFFFF),
                      oddRowColor: Colors.amber[200],
                      expandedBackgroundColor: const Color(0xe66c59cf),
                      headerBorder: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.transparent),
                      ),
                      expandedShape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.amber),
                      ),

                      // Pagination theme
                      paginationSize: 48,
                      paginationSelectedFillColor: const Color(0xFF6c59cf),
                      paginationSelectedTextColor: Colors.white,

                      // Edit dialog theme
                      editDialogTitleStyle: const TextStyle(
                        color: Color(0xe66c59cf),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      editDialogShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      editCancelButtonTextStyle: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      editInputDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    child: ExpandableDataTable(
                      headers: [
                        ExpandableColumn<int>(
                          columnTitle: "ID",
                          columnFlex: 1,
                          isEditable: false,
                        ),
                        ExpandableColumn<ImageProvider>(
                          columnTitle: "Picture",
                          columnFlex: 2,
                          isEditable: false,
                          // Example: custom cellBuilder with rounded corners and cover fit.
                          cellBuilder: (context, value) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple[300],
                              ),
                              height: 48,
                              width: 48,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipOval(
                                  child: Image(
                                    image: value as ImageProvider,
                                    fit: BoxFit.cover,
                                    frameBuilder:
                                        (
                                          context,
                                          child,
                                          frame,
                                          wasSynchronouslyLoaded,
                                        ) {
                                          if (wasSynchronouslyLoaded) {
                                            return child;
                                          }
                                          return AnimatedOpacity(
                                            opacity: frame == null ? 0 : 1,
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            child: child,
                                          );
                                        },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        ExpandableColumn<String>(
                          columnTitle: "First name",
                          columnFlex: 2,
                          hintText: "Enter first name",
                        ),
                        ExpandableColumn<String>(
                          columnTitle: "Last name",
                          columnFlex: 2,
                        ),
                        ExpandableColumn<DateTime>(
                          columnTitle: "Birth Date",
                          columnFlex: 2,
                          cellType: const DateTimeCellType(),
                        ),
                        ExpandableColumn<int>(
                          columnTitle: "Age",
                          columnFlex: 1,
                        ),
                        ExpandableColumn<String>(
                          columnTitle: "Email",
                          columnFlex: 4,
                        ),
                      ],
                      rows: rows,
                      isEditable: true,
                      pageSize: 8,
                      visibleColumnCount: visibleCount,

                      // Optional parameters for the default edit dialog
                      editDialogTitle: 'Edit User',
                      editSaveLabel: 'Save User',
                      editCancelLabel: 'Cancel',

                      // Callbacks
                      onRowChanged: (newRow, originalIndex) {
                        print(newRow.cells[1].value);
                      },
                      onPageChanged: (page) {
                        print(page);
                      },
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class DateTimeCellType extends CellType<DateTime> {
  const DateTimeCellType();

  @override
  Widget buildTitleCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(toDisplayString(value, '-'), style: textStyle);
  }

  @override
  Widget buildExpansionCell(
    BuildContext context,
    DateTime? value,
    TextStyle? textStyle,
  ) {
    return Text(toDisplayString(value, '-'), style: textStyle);
  }

  @override
  int compare(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;
    return a.compareTo(b);
  }

  @override
  Widget? buildEditField(
    BuildContext context,
    DateTime? value,
    ValueChanged<DateTime?> onChanged, {
    bool isEditable = true,
    String? hintText,
    InputDecoration? baseDecoration,
  }) {
    return TextButton(
      onPressed: isEditable
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(picked);
            }
          : null,
      style: TextButton.styleFrom(alignment: Alignment.centerLeft),
      child: Text(toDisplayString(value, 'Select date')),
    );
  }

  @override
  String toDisplayString(DateTime? value, String placeholder) {
    if (value == null) return placeholder;
    return '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
  }
}
