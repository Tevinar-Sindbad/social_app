part of '../routes.dart';

/// Absolute path for the posts shell entry route.
const postsRoutePath = '/';

/// Absolute path for the full-screen post-creation route.
const addNewPostRoutePath = '/add-new-post';

/// Absolute path for the full-screen post viewer route.
const postViewerRoutePath = '/post-viewer';

/// Root route for the post tab inside the signed-in app shell.
///
/// The posts list remains the tab entry point inside the signed-in app shell.
class PostsPageRoute extends GoRouteData with $PostsPageRoute {
  /// Creates a [PostsPageRoute].
  const PostsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => serviceLocator<PostListBloc>(),
      child: const PostsPage(),
    );
  }
}

/// Route to the post-creation screen.
///
/// The editor owns user-specific form state, so [PostEditorBloc] is created at
/// the route boundary instead of being shared globally across sessions.
///
/// This route lives outside the signed-in app shell so the editor can open
/// full-screen without the persistent bottom navigation bar.
@TypedGoRoute<AddNewPostPageRoute>(path: addNewPostRoutePath)
class AddNewPostPageRoute extends GoRouteData with $AddNewPostPageRoute {
  /// Creates a [AddNewPostPageRoute].
  const AddNewPostPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => serviceLocator<PostEditorBloc>(),
      child: const AddNewPostPage(),
    );
  }
}

/// Route to a specific post viewer.
///
/// The target post is identified by [postId], which is parsed from the route
/// parameters by the router before this page is built.
///
/// This route lives outside the signed-in app shell so the viewer can open
/// full-screen without the persistent bottom navigation bar.
@TypedGoRoute<PostViewerPageRoute>(path: postViewerRoutePath)
class PostViewerPageRoute extends GoRouteData with $PostViewerPageRoute {
  /// Creates a [PostViewerPageRoute].
  const PostViewerPageRoute({required this.postId});

  /// Identifier of the post to display.
  final String postId;

  @override
  Widget build(BuildContext context, GoRouterState state) => PostViewerPage(
    postId: postId,
  );
}
