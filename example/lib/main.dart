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

  late List<ExpandableColumn<dynamic>> headers;
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
    headers = [
      ExpandableColumn<int>(columnTitle: "ID", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "First name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Last name", columnFlex: 2),
      ExpandableColumn<String>(columnTitle: "Maiden name", columnFlex: 2),
      ExpandableColumn<int>(columnTitle: "Age", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 1),
      ExpandableColumn<String>(columnTitle: "Email", columnFlex: 4),
    ];

    rows = userList.map<ExpandableRow>((e) {
      return ExpandableRow(cells: [
        ExpandableCell<int>(columnTitle: "ID", value: e.id),
        ExpandableCell<String>(columnTitle: "First name", value: e.firstName),
        ExpandableCell<String>(columnTitle: "Last name", value: e.lastName),
        ExpandableCell<String>(columnTitle: "Maiden name", value: e.maidenName),
        ExpandableCell<int>(columnTitle: "Age", value: e.age),
        ExpandableCell<String>(columnTitle: "Gender", value: e.gender),
        ExpandableCell<String>(columnTitle: "Email", value: e.email),
      ]);
    }).toList();
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
              contentPadding: const EdgeInsets.all(12),
              headerTextMaxLines: 2,
              rowTextMaxLines: 2,
              rowTextOverflow: TextOverflow.ellipsis,
              headerColor: Colors.amber[400],
              headerSortIconColor: const Color(0xFF6c59cf),
              headerHeight: 56,
              rowColor: Colors.green,
              evenRowColor: const Color(0xFFFFFFFF),
              oddRowColor: Colors.amber[200],
              paginationSize: 48,
              headerBorder: const BorderSide(
                color: Colors.black,
                width: 1,
              ),
              shape: Border.all(color: Colors.black),
              collapsedShape: Border.all(color: Colors.black, width: 0.3),
              paginationSelectedFillColor: const Color(0xFF6c59cf),
              paginationSelectedTextColor: Colors.white,
            ),
            child: ExpandableDataTable(
              headers: headers,
              rows: rows,
              multipleExpansion: false,
              isEditable: true,
              pageSize: 8,
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
            row.cells[1].value = "x3";
            onSuccess(row);
          },
        ),
      ),
    );
  }
}
