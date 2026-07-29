import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// Data-layer representation of one post payload returned by the backend.
class PostModel {
  /// Creates a [PostModel].
  PostModel({
    required this.id,
    required this.posterId,
    required this.posterName,
    required this.title,
    required this.content,
    required this.imageRedirectUrl,
    required this.topics,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a [PostModel] from a backend JSON payload.
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final poster = JsonReader.readObject(json, 'poster');

    return PostModel(
      id: JsonReader.readString(json, 'id'),
      posterId: JsonReader.readString(poster, 'id'),
      posterName: JsonReader.readString(poster, 'name'),
      title: JsonReader.readString(json, 'title'),
      content: JsonReader.readString(json, 'content'),
      imageRedirectUrl: JsonReader.readString(json, 'imageRedirectUrl'),
      topics: JsonReader.readStringList(
        json,
        'topics',
      ).map(PostTopic.fromValue).toList(),
      createdAt: JsonReader.readDateTime(json, 'createdAt'),
      updatedAt: JsonReader.readDateTime(json, 'updatedAt'),
    );
  }

  /// Stable post identifier.
  final String id;

  /// Stable identifier of the user who created the post.
  final String posterId;

  /// Display name of the post author.
  final String posterName;

  /// Post title shown in lists and detail pages.
  final String title;

  /// Main textual content of the post.
  final String content;

  /// Absolute backend redirect URL returned by the backend for the post image.
  final String imageRedirectUrl;

  /// Topics associated with the post.
  final List<PostTopic> topics;

  /// Post creation timestamp.
  final DateTime createdAt;

  /// Post last-update timestamp.
  final DateTime updatedAt;

  /// Returns a copy of this model with the provided fields replaced.
  PostModel copyWith({
    String? id,
    String? posterId,
    String? posterName,
    String? title,
    String? content,
    String? imageRedirectUrl,
    List<PostTopic>? topics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      title: title ?? this.title,
      content: content ?? this.content,
      imageRedirectUrl: imageRedirectUrl ?? this.imageRedirectUrl,
      topics: topics ?? this.topics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the data model into the domain [Post] entity.
  Post toEntity() {
    return Post(
      id: id,
      posterId: posterId,
      posterName: posterName,
      title: title,
      content: content,
      imageRedirectUrl: imageRedirectUrl,
      topics: topics,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
