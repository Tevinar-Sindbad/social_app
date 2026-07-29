import 'package:drift/drift.dart';

/// Table for storing posts cached in the local database.
class CachedPosts extends Table {
  /// The unique identifier for the post.
  /// This is the primary key for the table.
  TextColumn get id => text()();

  /// The identifier of the user who posted the post.
  TextColumn get posterId => text()();

  /// The title of the post.
  TextColumn get title => text()();

  /// The content of the post.
  TextColumn get content => text()();

  /// The backend redirect URL of the image associated with the post.
  TextColumn get imageRedirectUrl => text().named('image_url')();

  /// The JSON string representing the topics of the post.
  TextColumn get topicsJson => text()();

  /// The date and time when the post was created.
  DateTimeColumn get createdAt => dateTime()();

  /// The date and time when the post was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// The name of the user who posted the post.
  TextColumn get posterName => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
