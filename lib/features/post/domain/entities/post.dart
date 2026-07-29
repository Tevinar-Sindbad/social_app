import 'package:social_app/features/post/domain/value_objects/post_topic.dart';

/// Domain entity representing a post post displayed in the app.
class Post {
  /// Creates a [Post].
  const Post({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageRedirectUrl,
    required this.topics,
    required this.createdAt,
    required this.updatedAt,
    required this.posterName,
  });

  /// Unique post identifier.
  final String id;

  /// Identifier of the user who created the post.
  final String posterId;

  /// Post title shown in lists and detail views.
  final String title;

  /// Main text content of the post post.
  final String content;

  /// Backend redirect URL of the post cover image.
  final String imageRedirectUrl;

  /// Topics associated with the post.
  final List<PostTopic> topics;

  /// Creation date of the post.
  final DateTime createdAt;

  /// Last update date of the post.
  final DateTime updatedAt;

  /// Poster name resolved for display purposes.
  final String posterName;
}
