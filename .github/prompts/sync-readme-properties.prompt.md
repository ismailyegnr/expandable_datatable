agent: "agent"
description: "Sync README property tables with the actual code — run this on every new release"

---

## Task

Compare the property documentation in `README.md` against the actual Dart source code and add any missing properties. Run this every time a new version is released.

## Steps

1. Read the current `README.md` in full.
2. Read `lib/src/expandable_datatable.dart` to get all constructor parameters of `ExpandableDataTable`.
3. Read `lib/src/utility/expandable_theme.dart` to get all fields of `ExpandableThemeData`.
4. For each class, diff the properties found in code against the properties documented in the README tables.
5. For every property present in code but **missing** from the README, add a new row to the correct table section.

## Rules

- **Do not change or remove any existing rows.**
- **Do not add default values** to descriptions — keep them concise and behavior-focused.
- Match the column widths and formatting style of the surrounding table rows exactly.
- Place each new row in the correct existing section (Header, Rows, Expansion panel & icons, Images, Edit Dialog, Pagination). If a property does not fit any existing section, append a new section in the same style at the end of the `ExpandableThemeData` tables.
- Skip deprecated properties (`@Deprecated`).
- Descriptions should match the tone and length of the existing rows — short, imperative, one line.
