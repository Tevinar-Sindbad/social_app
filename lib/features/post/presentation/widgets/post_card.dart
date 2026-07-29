import 'package:flutter/material.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/text/calculate_reading_time.dart';

/// A post card widget that displays a summary of a post in the posts page.
class PostCard extends StatelessWidget {
  /// Creates a [PostCard].
  const PostCard({required this.post, super.key});

  /// The post.
  final Post post;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
      child: Material(
        color: AppPallete.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => PostViewerPageRoute(postId: post.id).push<void>(context),
          child: Container(
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: post.topics
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 10,
                                  bottom: 5,
                                ),
                                child: Chip(label: Text(e.value)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text('${calculateReadingTime(post.content)} min'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
