<!-- BEGIN:flutter-agent-rules -->

# This is NOT the Flutter you know

This repository may use Flutter, Dart, and package versions that differ from your training data. Read `pubspec.yaml` before writing code and follow the APIs and patterns that match the current repo dependencies. Heed deprecation notices.

This repository uses project-specific architectural rules. Before making structural, routing, state-management, or layering changes, read `architecture.md` and treat its rules as mandatory.

When making code changes, if generated files may be affected or you are not certain, run `dart run build_runner build --delete-conflicting-outputs` and review the generated diff. Validate the result with `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test` before finishing. If one of these checks is not relevant or cannot run, say so explicitly.

<!-- END:flutter-agent-rules -->
