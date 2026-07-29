import 'package:drift/drift.dart';

/// Singleton table storing the current cached profile projection.
class CurrentProfiles extends Table {
  /// Singleton row identifier used to keep at most one cached profile row.
  IntColumn get singletonKey => integer().withDefault(const Constant(0))();

  /// Stable app user identifier.
  TextColumn get id => text()();

  /// Public profile name.
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {singletonKey};
}
