# ExpandableDataTable

ExpandableDataTable is a Flutter library for dealing with displaying and editing data in tabular view.

## Features

- Row sorting
- Flexible column sizes
- Expandable rows
- Row pagination
- Editable rows
- Customizable edit dialogs
- Customizable pagination widget
- Customizable expansion content
- Styling rows and header columns

<br />

**ExpandableDataTable Parameters:**

| Name                   | Description                                                              |
|------------------------|--------------------------------------------------------------------------|
| headers                | Header list of data columns                                              |
| rows                   | List of the data rows                                                    |
| pageSize               | Number of rows to be used on a single page                               |
| visibleColumnCount     | Number of columns to show in the headers                                 |
| multipleExpansion      | Flag indicating that multiple expansions are enabled for rows            |
| isEditable             | Flag indicating whether the rows are editable                            |
| onRowChanged           | The callback that is called when a row is changed with edit dialog       |
| onPageChanged          | The callback that is called when the page changed with pagination widget |
| renderEditDialog       | Render function that builds a custom edit dialog widget                  |
| renderCustomPagination | Render function that builds a custom pagination widget                   |
| renderExpansionContent | Render function that builds custom expansion container for all rows      |

<br />

**ExpandableThemeData Parameters:**

| Name                          | Description                                                              |
|-------------------------------|--------------------------------------------------------------------------|
| rowHeight                     | Height of the rows                                                       |
| headerTextStyle               | Text style of header row                                                 |
| rowTextStyle                  | Text style of all rows                                                   |
| contentPadding                | Padding for all header and data rows                                     |
| headerTextMaxLines            | Maximum number of lines for header text to span                          |
| rowTextMaxLines               | Maximum number of lines for row text to span                             |
| rowTextOverflow               | Visual overflow of the row's cell text                                   |
| expandedTextStyle             | Text style of expansion content                                          |
| headerColor                   | Background color of header row                                           |
| headerSortIconColor           | Color of the header sort arrow icon                                      |
| headerHeight                  | Height of the header widget                                              |
| rowBorder                     | **DEPRECATED**. Border style of all rows. Use `shape` instead.           |
| expandedBorderColor           | **DEPRECATED**. Expansion border color. Use `expandedShape` instead.     |
| rowColor                      | Background color of rows                                                 |
| evenRowColor                  | Background color of the even indexed rows                                |
| oddRowColor                   | Background color of the odd indexed rows                                 |
| expansionAnimationStyle       | Expansion animation curve and duration                                                      |
| shape                         | The rows' border shape when the expandable content is collapsed          |
| expandedShape                 | The rows' border shape when the expandable content is expanded           |
| headerBorder                  | Border style of header row                                               |
| editIcon                      | Icon image showing editing feature                                       |
| expansionIcon                 | Icon image expanding expansion content                                   |
| paginationSize                | Size of the default pagination widget                                    |
| paginationTextStyle           | TextStyle of the page numbers for default pagination widget              |
| paginationSelectedTextColor   | Color of the selected cell's page number for default pagination widget   |
| paginationUnselectedTextColor | Color of the unselected cells' page number for default pagination widget |
| paginationSelectedFillColor   | Background fill color of the selected cell for default pagination widget |
| paginationBorderColor         | Border color for default pagination widget                               |
| paginationBorderRadius        | Border radius value for default pagination widget                        |
| paginationBorderWidth         | Border width value for default pagination widget                         |

## Usage

1. To use this package, add expandable_datatable as a dependency in your pubspec.yaml file.

2. Import the package

```dart
import ‘package:expandable_datatable/expandable_datatable.dart’;
```

3. Create data to use in the data table

Create the list of the headers to be used in data table with types. Header list should be in a prioritized order, all columns have a flex value that all cells inside that column will be used.

```dart
  List<ExpandableColumn<dynamic>> headers = [
    ExpandableColumn<int>(columnTitle: "ID", columnFlex: 1),
    ExpandableColumn<String>(columnTitle: "First name", columnFlex: 2),
    ExpandableColumn<String>(columnTitle: "Last name", columnFlex: 2),
    ExpandableColumn<String>(columnTitle: "Maiden name", columnFlex: 2),
    ExpandableColumn<int>(columnTitle: "Age", columnFlex: 1),
    ExpandableColumn<String>(columnTitle: "Gender", columnFlex: 2),
    ExpandableColumn<String>(columnTitle: "Email", columnFlex: 4),
  ];
```

Create the list of the rows to be used in data table. All row list elements must contain all columns for lists.

```dart
  List<ExpandableRow> rows = userList.map<ExpandableRow>((e) {
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
```

4. Code

```dart
  void createDataSource() {...}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expandable Datatable Example"),
      ),
      body: ExpandableTheme(
        data: ExpandableThemeData(
          contentPadding: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          expandedShape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.amber),
          ),
          rowHeight: 60,
        ),
        child: ExpandableDataTable(
          headers: headers,
          rows: rows,
          visibleColumnCount: 4,
        ),
      ),
    );
  }
```

## Screenshots

#### Sorting the rows

<img src="https://raw.githubusercontent.com/ismailyegnr/expandable_datatable/master/screenshots/sorting.png" height="400" alt="Sort Screenshot"/>

#### Expansion feature

<img src="https://raw.githubusercontent.com/ismailyegnr/expandable_datatable/master/screenshots/expansion.png" height="400" alt="Expansion Screenshot"/>

#### Edit rows dialog (Customizable)

<img src="https://raw.githubusercontent.com/ismailyegnr/expandable_datatable/master/screenshots/editing.png" height="400" alt="Editing Screenshot"/>

#### Styling

<img src="https://raw.githubusercontent.com/ismailyegnr/expandable_datatable/master/screenshots/styling.png" height="400" alt="Styling Screenshot"/>

## License

[MIT](https://choosealicense.com/licenses/mit/)