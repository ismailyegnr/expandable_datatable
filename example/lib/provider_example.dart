import 'dart:math';

import 'package:expandable_datatable/expandable_datatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: ChangeNotifierProvider<MainViewModel>(
        create: (context) => MainViewModel(),
        child: Consumer<MainViewModel>(
          builder: (context, viewModel, _) {
            return Scaffold(
              appBar: AppBar(title: const Text('Provider Example')),
              body: Column(
                children: [
                  Row(
                    children: [
                      // add user button
                      ElevatedButton(
                        onPressed: () {
                          viewModel.addUser(generateRandomUser());
                        },
                        child: const Text('Add User'),
                      ),
                      // remove user button
                      ElevatedButton(
                        onPressed: () {
                          viewModel.users.isNotEmpty
                              ? viewModel.removeUser(viewModel.users.first)
                              : null;
                        },
                        child: const Text('Remove User'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.refresh();
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : buildExpandableTheme(context, viewModel.users),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ExpandableTheme buildExpandableTheme(BuildContext context, List<User> users) {
    return ExpandableTheme(
      data: ExpandableThemeData(
        context,
        rowBorder: const BorderSide(color: Colors.amber),
        expandedBorderColor: Colors.transparent,
        paginationSize: 48,
      ),
      child: ExpandableDataTable(
        rows: rows(users),
        headers: headers,
        visibleColumnCount: 3,
        pageSize: 5
      ),
    );
  }

  User generateRandomUser() {
    final random = Random();
    return User(
      name: 'User ${random.nextInt(100)}',
      email: 'user${random.nextInt(100)}@naver.com',
      password: '1234',
    );
  }

  List<ExpandableColumn<dynamic>> headers = [
    ExpandableColumn<String>(columnTitle: "name", columnFlex: 1),
    ExpandableColumn<String>(columnTitle: "email", columnFlex: 1),
    ExpandableColumn<String>(columnTitle: "password", columnFlex: 1),
  ];

  List<ExpandableRow> rows(List<User> userList) {
    return userList.map<ExpandableRow>((e) {
      return ExpandableRow(
        cells: [
          ExpandableCell<String>(columnTitle: "name", value: e.name),
          ExpandableCell<String>(columnTitle: "email", value: e.email),
          ExpandableCell<String>(columnTitle: "password", value: e.password),
        ],
      );
    }).toList();
  }
}

class MainViewModel extends ChangeNotifier {
  List<User> users = [
    User(name: 'User 1', email: 'user1@naver.com', password: '1234'),
    User(name: 'User 2', email: 'user2@naver.com', password: '1234'),
    User(name: 'User 3', email: 'user3@naver.com', password: '1234'),
    User(name: 'User 4', email: 'user4@naver.com', password: '1234'),
  ];
  bool isLoading = false;

  MainViewModel();

  void addUser(User user) {
    users.add(user);
    notifyListeners();
  }

  void removeUser(User user) {
    users.remove(user);
    notifyListeners();
  }

  void refresh() {
    isLoading = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 50), () {
      isLoading = false;
      notifyListeners();
    });
  }
}

class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });
}
