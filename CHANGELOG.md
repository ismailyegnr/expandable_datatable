# 0.5.0 - 14/08/2026

- Introduced an extensible cell type architecture and modularized data table components.

## 0.4.1 - 21/07/2026

- Fixed a crash when saving the edit dialog for a row containing a null cell value.
- Fixed null cell values displaying as the literal string "null" in the edit dialog.
- Fixed `searchTitleValue` throwing when a row has no cell for the given column title; it now returns `null`.
- Fixed the double input formatter rejecting single-digit values (e.g. `"5"`) in the edit dialog.
- Expanded test coverage: null-cell editing, numeric editing, exceptions, sort behavior with duplicate keys, and `expansionAnimationStyle`.

## 0.4.0 - 12/03/2026

- Added `cellBuilder` property to `ExpandableColumn` which enables customizable cell rendering per column.
- Replaced Switch widget for boolean value edit in EditDialog.

## 0.3.0 - 07/03/2026

- Added `ImageProvider` as a new `ExpandableColumn` type to render images as cells.
- Added image size properties to `ExpandableTheme`.
- Added `isSortable` property to `ExpandableColumn`.
- Added image screenshots to README.

## 0.2.4 - 03/03/2026

- Added `expansionIconAffinity` property for changing expansion icon place.
- Added Codecov coverage analyzer.
- Improved README for easier reading.

## 0.2.3 - 24/02/2026

- Fixed README screenshots.

## 0.2.2 - 24/02/2026

- Improved edit dialog customization, making it easier to tailor the edit UI and its behavior to app needs.
- Added automated tests to improve stability and prevent regressions.
- Updated README.

## 0.2.1 - 18/02/2026

- Added new theme properties `expandedBackgroundColor`, `expansionChildrenPadding`, `expansionCellPadding`, `iconColor`, and `expandedIconColor`.
- Fixed `expansionAnimationStyle` curve now correctly applies to animations.
- Updated README composition.

## 0.2.0 - 07/02/2026

- Enhanced the `onRowChanged` callback to include the `originalIndex` to improve external state management. ([#19](https://github.com/ismailyegnr/expandable_datatable/pull/19))
- **Major Refactoring:** Restructured the ExpandableThemeData constructor and improved docs. ([#20](https://github.com/ismailyegnr/expandable_datatable/pull/20))

## 0.1.1 - 29/01/2026

- Fix table not updating when data was changed externally (e.g., via Provider) ([#4](https://github.com/ismailyegnr/expandable_datatable/issues/4))
- Fix bug where the `multipleExpansion` parameter was not working.
- Set `isEditable` default property to `false`.
- **Major Refactoring:** Switch the table to a stateless model by removing internal data handling. Editing now requires external state management via the `onRowChanged` callback.
- Add a new example demonstrating Provider integration.

## 0.1.0 - 21/01/2026

- Add rowHeight feature
- Remove rowBorder, add shape and expandedShape parameters
- Change default expansionIcon to Icons.expand_more
- Add expansionAnimationStyle to theme
- Fix trailingWidth logic bugs
- Update expansionTile logic

## 0.0.8 - 26/12/2025

- Fix the Icon overflow on editable option ([#10](https://github.com/ismailyegnr/expandable_datatable/pull/10))
- Fix page numbering and button visibility ([#11](https://github.com/ismailyegnr/expandable_datatable/pull/11))
- Add missing README parameter

## 0.0.7 - 07/03/2023

- Fix Scrollbar ScrollPosition error
- Add option to disable row editing

## 0.0.6 - 10/08/2022

- Fix README table

## 0.0.5 - 10/08/2022

- Add content padding parameter for all rows
- Remove unnecessary code blocks
- Add parameters table to README

## 0.0.3 - 10/02/2022

- Add enable/disable multiple expansion parameter

## 0.0.2 - 09/24/2022

- Fix README screenshots
- Fix code warnings and analysis

## 0.0.1 - 09/24/2022

Initial release

- Create the package template
- Add theme class for styling
- Provide render widget functions for customizable widgets
- Make it suitable for web
