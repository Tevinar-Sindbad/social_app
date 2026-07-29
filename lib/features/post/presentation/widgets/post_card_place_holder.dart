import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// A placeholder widget for the post card while the post data is loading.
class PostCardPlaceholder extends StatelessWidget {
  /// Creates a [PostCardPlaceholder].
  const PostCardPlaceholder({super.key});

  @override
  /// The build.
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16).copyWith(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fake chips row
              Row(
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 24,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppPallete.primaryBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Fake title
              Container(
                height: 22,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppPallete.primaryBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 22,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: AppPallete.primaryBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          // Fake reading time
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: AppPallete.primaryBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
