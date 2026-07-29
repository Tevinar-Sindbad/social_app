import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/post/presentation/blocs/post_viewer/post_viewer_bloc.dart';
import 'package:social_app/features/post/presentation/text/calculate_reading_time.dart';

/// Page that displays the content of a post.
class PostViewerPage extends StatefulWidget {
  /// Creates a [PostViewerPage].
  const PostViewerPage({
    required this.postId,
    super.key,
  });

  /// The stable post identifier used to load the viewer content.
  ///
  /// The page intentionally accepts `postId` instead of a full post object so
  /// the same route can be opened from deep links and push notifications. The
  /// viewer then relies on a cache-first `observe...` flow so it can still
  /// render quickly without requiring a rich navigation payload.
  final String postId;

  @override
  State<PostViewerPage> createState() => _PostViewerPageState();
}

class _PostViewerPageState extends State<PostViewerPage> {
  /// Last local image path used to prepare the viewer image.
  ///
  /// This lets the page detect when repeated cache-first bloc emissions still
  /// point to the same file, so it can reuse the existing preparation future.
  String? _preparedImagePath;

  /// Prepared image future reused while the resolved local image path stays
  /// unchanged.
  ///
  /// Reusing the same future avoids restarting precache work for identical
  /// files, which helps prevent a subtle first-frame image blink.
  Future<ImageProvider<Object>?>? _preparedImageFuture;

  /// Builds the post viewer page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<PostViewerBloc>(),
        child: Builder(
          builder: _loadPostContent,
        ),
      ),
    );
  }

  Widget _loadPostContent(BuildContext context) {
    return BlocBuilder<PostViewerBloc, PostViewerState>(
      builder: (context, state) {
        if (state is PostViewerInitial) {
          context.read<PostViewerBloc>().add(
            LoadPost(
              postId: widget.postId,
            ),
          );
          return const SizedBox();
        } else if (state is PostViewerLoading) {
          return const Center(child: Loader());
        } else if (state is PostViewerFailure) {
          return Center(
            child: Text(
              state.error,
            ),
          );
        } else {
          return _buildPostContent(context, state as PostViewerSuccess);
        }
      },
    );
  }

  Widget _buildPostContent(BuildContext context, PostViewerSuccess state) {
    final post = state.post;
    return FutureBuilder(
      future: _resolvePreparedPostImage(context, state.imageFile),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Loader());
        }
        return Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'By ${post.posterName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${formatToDay(post.updatedAt)} . '
                    '${calculateReadingTime(post.content)} min',
                    style: const TextStyle(
                      color: AppPallete.darkForegroundColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _displayPostImage(asyncSnapshot.data),
                  const SizedBox(height: 20),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 16, height: 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _displayPostImage(ImageProvider<Object>? imageProvider) {
    if (imageProvider == null) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text('Image unavailable'),
      );
    } else {
      return Image(
        image: imageProvider,
        gaplessPlayback: true,
        semanticLabel: 'Post image',
        errorBuilder: (_, _, _) {
          return Container(
            height: 220,
            alignment: Alignment.center,
            child: const Text('Image unavailable'),
          );
        },
      );
    }
  }

  /// Reuses the same prepared image future while the resolved file path stays
  /// unchanged, which avoids a transient reset when the cache-first post stream
  /// emits the cached post and then the refreshed remote post.
  Future<ImageProvider<Object>?> _resolvePreparedPostImage(
    BuildContext context,
    File? imageFile,
  ) {
    final imagePath = imageFile?.path;

    if (_preparedImageFuture != null && _preparedImagePath == imagePath) {
      return _preparedImageFuture!;
    }

    final preparedImageFuture = _preparePostImage(context, imageFile);
    _preparedImagePath = imagePath;
    _preparedImageFuture = preparedImageFuture;

    return preparedImageFuture;
  }

  Future<ImageProvider<Object>?> _preparePostImage(
    BuildContext context,
    File? imageFile,
  ) async {
    if (imageFile == null) {
      return null;
    }

    final resolvedImageProvider = FileImage(imageFile);

    if (!context.mounted) {
      return resolvedImageProvider;
    }

    await precacheImage(resolvedImageProvider, context);

    return resolvedImageProvider;
  }
}
