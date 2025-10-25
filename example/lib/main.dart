import 'dart:convert';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.light(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Users> userList = [];

  late List<ExpandableColumn> headers;
  late List<ExpandableRow> rows;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    userList = await getUsers();
    createLists();

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Users>> getUsers() async {
    final String response = await rootBundle.loadString('asset/dumb.json');
    final data = await json.decode(response);
    API apiData = API.fromJson(data);

    if (apiData.users == null) {
      return [];
    }

    return apiData.users!;
  }

  void createLists() {
    headers = [
      ExpandableColumn(
          title: "ID",
          accessor: "id",
          sortable: false,
          editable: false,
          flex: 1),
      ExpandableColumn(
          title: "Image",
          accessor: "img",
          editable: false,
          sortable: false,
          flex: 2),
      ExpandableColumn(title: "First Name", accessor: "first_name", flex: 2),
      ExpandableColumn(title: "Active", accessor: "is_active", flex: 1),
      ExpandableColumn(title: "Last Name", accessor: "last_name", flex: 2),
      ExpandableColumn(title: "Maiden Name", accessor: "maiden_name", flex: 2),
      ExpandableColumn(title: "Age", accessor: "age", flex: 1),
      ExpandableColumn(title: "Gender", accessor: "gender"),
      ExpandableColumn(title: "Email", accessor: "email"),
    ];

    rows = userList
        .map((val) => ExpandableRow(cells: [
              NumberCell(accessor: "id", value: val.id!),
              StringCell(
                accessor: "img",
                value: val.image!,
                render: SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.network(
                      val.image!,
                    ),
                  ),
                ),
              ),
              StringCell(accessor: "first_name", value: val.firstName!),
              StringCell(accessor: "last_name", value: val.lastName!),
              BooleanCell(accessor: "is_active", value: val.isActive!),
              StringCell(accessor: "maiden_name", value: val.maidenName!),
              NumberCell(accessor: "age", value: val.age!),
              StringCell(accessor: "gender", value: val.gender!),
              StringCell(accessor: "email", value: val.email!),
            ]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: !_isLoading
            ? LayoutBuilder(builder: (context, constraints) {
                int visibleCount = 3;
                if (constraints.maxWidth < 600) {
                  visibleCount = 3;
                } else if (constraints.maxWidth < 800) {
                  visibleCount = 4;
                } else if (constraints.maxWidth < 1000) {
                  visibleCount = 5;
                } else {
                  visibleCount = 6;
                }

                return ExpandableTheme(
                  data: ExpandableThemeData(
                    context,
                    contentPadding: const EdgeInsets.all(20),
                    expandedBorderColor: Colors.transparent,
                    paginationSize: 48,
                    headerHeight: 56,
                    headerColor: Colors.amber[400],
                    headerBorder: const BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    evenRowColor: const Color(0xFFFFFFFF),
                    oddRowColor: Colors.amber[200],
                    rowBorder: const BorderSide(
                      color: Colors.black,
                      width: 0.3,
                    ),
                    rowColor: Colors.green,
                    headerTextMaxLines: 4,
                    headerSortIconColor: const Color(0xFF6c59cf),
                    paginationSelectedFillColor: const Color(0xFF6c59cf),
                    paginationSelectedTextColor: Colors.white,
                  ),
                  child: ExpandableDataTable(
                    headers: headers,
                    rows: rows,
                    multipleExpansion: false,
                    isEditable: true,
                    onRowChanged: (newRow) {
                      print(newRow.cells[01].value);
                    },
                    onPageChanged: (page) {
                      print(page);
                    },
                    renderEditDialog: (row, onSuccess) =>
                        _buildEditDialog(row, onSuccess),
                    visibleColumnCount: visibleCount,
                  ),
                );
              })
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEditDialog(
      ExpandableRow row, Function(ExpandableRow) onSuccess) {
    return AlertDialog(
      title: SizedBox(
        height: 300,
        child: TextButton(
          child: const Text("Change name"),
          onPressed: () {
            onSuccess(row);
          },
        ),
      ),
    );
  }
}
