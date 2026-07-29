import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/post/data/models/post_model.dart';

/// Data-layer representation of one cursor-based post list slice.
class PostListSliceModel {
  /// Creates a [PostListSliceModel].
  PostListSliceModel({
    required this.items,
    required this.nextCursor,
  });

  /// Builds a post list slice model from a backend JSON payload.
  factory PostListSliceModel.fromJson(Map<String, dynamic> json) {
    final items = JsonReader.readList(json, 'items');

    return PostListSliceModel(
      items: items
          .map(
            (item) => PostModel.fromJson(JsonReader.asObject(item, 'items[]')),
          )
          .toList(),
      nextCursor: JsonReader.readNullableString(json, 'nextCursor'),
    );
  }

  /// Posts returned in the current list slice.
  final List<PostModel> items;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
