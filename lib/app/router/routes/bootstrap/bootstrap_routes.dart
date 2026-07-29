part of '../routes.dart';

/// Path for the initial-loading route.
const initialLoadingRoutePath = '/initial-loading';

@TypedGoRoute<InitialLoadingPageRoute>(path: initialLoadingRoutePath)
/// A route for initial loading page.
class InitialLoadingPageRoute extends GoRouteData
    with $InitialLoadingPageRoute {
  /// Creates a [InitialLoadingPageRoute].
  const InitialLoadingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InitialLoadingPage();
}
