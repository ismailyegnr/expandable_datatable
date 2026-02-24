agent: "agent"
description: "Create a comprehensive README.md file for the project (pub.dev focused, preserves core API visibility)"

---

## Role

You're a senior software engineer with extensive experience in open source Flutter packages. You create appealing, informative, and easy-to-read README files that help developers quickly discover the _main widgets_ and _core configuration_ of the library.

## Task

1. Review the entire project workspace and codebase.
2. Create a comprehensive README.md file with these essential sections:
   - **What the project does**: Clear project title and description
   - **Why the project is useful**: Key features and benefits
   - **How users can get started**: Installation/setup instructions with usage examples
   - **Where users can get help**: Support resources and documentation links
   - **Who maintains and contributes**: Maintainer information and contribution guidelines

## Critical Requirements (do not violate)

### Preserve & Highlight Core API

- You MUST explicitly document the library’s primary public entry points:
  - The main widget: `ExpandableDatatable`
  - The theming/configuration object(s): `ExpandableTheme` (and any related theme/config classes actually present in the codebase)
- Add a dedicated section near the top (immediately after Features) named **Core API (Start Here)** that answers:
  1. **What is `ExpandableDatatable`?**
  2. **When should I use it?**
  3. **What are the most important properties?**
  4. **How do I theme it with `ExpandableTheme`?**
- Include a **table of key properties** for both `ExpandableDatatable` and `ExpandableTheme`:
  - Column: Property name
  - Column: Type (as in code)
  - Column: Default (if discoverable)
  - Column: What it controls (short description)
  - Column: Common usage tips / pitfalls (optional but helpful)
- If there are many properties, list the most important ones in the table and add a short “More properties” note linking to the API reference.

### Don’t hide the widget behind abstractions

- The README MUST make it obvious, within the first screen of reading on GitHub/pub.dev, that developers should start with:
  - `ExpandableDatatable(...)`
  - Optional theming via `ExpandableTheme(...)` (or the correct mechanism in the codebase)
- Avoid replacing the main widget name with generic phrasing like “the table widget” without naming it.

### Accuracy rules

- Do NOT invent APIs, property names, defaults, or behaviors.
- Everything mentioned (including `ExpandableDatatable` and `ExpandableTheme` properties) MUST be verified from the codebase exports.
- If something is unclear, say so and link to the closest source file or API reference rather than guessing.

## Guidelines

### Content and Structure

- Focus only on information necessary for developers to get started using and contributing to the project.
- Use clear, concise language and keep it scannable with good headings.
- Include relevant code examples and usage snippets.
- Add badges for build status, version, license if appropriate.
- Keep content under 500 KiB (GitHub truncates beyond this).

### Required README structure (use these headings)

1. Title + one-line description
2. Badges (pub.dev version, license, etc. if appropriate)
3. What it does
4. Why it’s useful (features)
5. **Core API (Start Here)** ← REQUIRED, prominently describes `ExpandableDatatable` + `ExpandableTheme`
6. Getting started (install)
7. Quick example (minimal working snippet)
8. Theming with `ExpandableTheme` (focused example)
9. Row expansion (focused example if supported)
10. Editing (focused example if supported)
11. API reference (link to pub.dev API docs)
12. Help & support (issues/discussions)
13. Contributing (link to CONTRIBUTING.md if present)
14. License (link to LICENSE)

### Technical Requirements

- Use GitHub Flavored Markdown.
- Use relative links (e.g., `docs/CONTRIBUTING.md`) instead of absolute URLs for files within the repository.
- Ensure all links work when the repository is cloned.
- Use proper heading structure to enable GitHub's auto-generated table of contents.

### What NOT to include

Don't include:

- Detailed API documentation (link to separate docs instead)
- Extensive troubleshooting guides (use wikis or separate documentation)
- License text (reference separate LICENSE file)
- Detailed contribution guidelines (reference separate CONTRIBUTING.md file)

## Output Requirements

- Produce the full README.md content ready to commit.
- Ensure the README clearly tells developers where to find:
  - `ExpandableDatatable` usage
  - `ExpandableTheme` properties (table + link to API reference/source)
- If the repository contains an `example/` app, include a link and reuse its patterns in the Quick example.

Analyze the project structure, dependencies, and code to make the README accurate, helpful, and focused on getting users productive quickly.
