import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/profile/data/models/profile_model.dart';
import 'package:social_app/features/profile/data/sources/profile_local_data_source.dart';

void main() {
  late AppDatabase database;
  late DriftProfileLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.test(NativeDatabase.memory());
    dataSource = DriftProfileLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('given no cached row then returns null', () async {
    final result = await dataSource.getCurrentProfile();

    expect(result, isNull);
  });

  test(
    'given a saved profile then returns it and replaces the singleton row on '
    'subsequent saves',
    () async {
      await dataSource.saveCurrentProfile(
        const ProfileModel(id: 'user-1', name: 'Alice'),
      );
      await dataSource.saveCurrentProfile(
        const ProfileModel(id: 'user-2', name: 'Bob'),
      );

      final result = await dataSource.getCurrentProfile();

      expect(result, isNotNull);
      expect(result!.id, 'user-2');
      expect(result.name, 'Bob');
    },
  );

  test(
    'given a saved profile when cleared then removes the cached row',
    () async {
      await dataSource.saveCurrentProfile(
        const ProfileModel(id: 'user-1', name: 'Alice'),
      );

      await dataSource.clearCurrentProfile();

      expect(await dataSource.getCurrentProfile(), isNull);
    },
  );
}
