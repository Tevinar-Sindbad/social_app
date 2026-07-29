part of '../routes.dart';

/// Typed route declaration for the authenticated app shell.
///
/// The shell contains two persistent branches:
/// - the post branch, centered on the posts list
/// - the chat branch, centered on the chats list
@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    // Post branch.
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<PostsPageRoute>(
          path: postsRoutePath,
        ),
      ],
    ),
    // Chat branch.
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatsPageRoute>(
          path: chatsRoutePath,
        ),
      ],
    ),
  ],
)
/// Route data that builds the persistent scaffold for signed-in navigation.
class AppShellRouteData extends StatefulShellRouteData {
  /// Creates a [AppShellRouteData].
  const AppShellRouteData();

  @override
  /// Builds the shared app shell that hosts the branch navigators.
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}
