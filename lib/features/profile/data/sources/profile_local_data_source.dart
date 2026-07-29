import 'package:drift/drift.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';

/// Local data source for the current cached profile projection.
abstract interface class ProfileLocalDataSource {
  /// Reads the cached profile projection, if any.
  Future<ProfileModel?> getCurrentProfile();

  /// Persists [profile] as the current cached profile projection.
  Future<void> saveCurrentProfile(ProfileModel profile);

  /// Clears the cached current profile projection.
  Future<void> clearCurrentProfile();
}

/// Drift-backed implementation of [ProfileLocalDataSource].
class DriftProfileLocalDataSource implements ProfileLocalDataSource {
  /// Creates a [DriftProfileLocalDataSource].
  DriftProfileLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<ProfileModel?> getCurrentProfile() async {
    final row = await (_database.select(
      _database.currentProfiles,
    )..where((table) => table.singletonKey.equals(0))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return ProfileModel(
      id: row.id,
      name: row.name,
    );
  }

  @override
  Future<void> saveCurrentProfile(ProfileModel profile) {
    return _database
        .into(_database.currentProfiles)
        .insertOnConflictUpdate(
          CurrentProfilesCompanion.insert(
            singletonKey: const Value(0),
            id: profile.id,
            name: profile.name,
          ),
        );
  }

  @override
  Future<void> clearCurrentProfile() {
    return _database.delete(_database.currentProfiles).go();
  }
}
