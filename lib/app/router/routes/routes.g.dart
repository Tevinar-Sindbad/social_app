// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $initialLoadingPageRoute,
  $signInPageRoute,
  $signUpPageRoute,
  $emailConfirmationPendingPageRoute,
  $newChatDraftFlowRoute,
  $chatMessagesPageRoute,
  $addNewPostPageRoute,
  $postViewerPageRoute,
  $profileNameOnboardingPageRoute,
  $appShellRouteData,
];

RouteBase get $initialLoadingPageRoute => GoRouteData.$route(
  path: '/initial-loading',
  hasOverriddenOnExit: false,
  factory: $InitialLoadingPageRoute._fromState,
);

mixin $InitialLoadingPageRoute on GoRouteData {
  static InitialLoadingPageRoute _fromState(GoRouterState state) =>
      const InitialLoadingPageRoute();

  @override
  String get location => GoRouteData.$location('/initial-loading');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInPageRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInPageRoute._fromState,
);

mixin $SignInPageRoute on GoRouteData {
  static SignInPageRoute _fromState(GoRouterState state) =>
      const SignInPageRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpPageRoute => GoRouteData.$route(
  path: '/sign-up',
  hasOverriddenOnExit: false,
  factory: $SignUpPageRoute._fromState,
);

mixin $SignUpPageRoute on GoRouteData {
  static SignUpPageRoute _fromState(GoRouterState state) =>
      const SignUpPageRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $emailConfirmationPendingPageRoute => GoRouteData.$route(
  path: '/confirm-email',
  hasOverriddenOnExit: false,
  factory: $EmailConfirmationPendingPageRoute._fromState,
);

mixin $EmailConfirmationPendingPageRoute on GoRouteData {
  static EmailConfirmationPendingPageRoute _fromState(GoRouterState state) =>
      EmailConfirmationPendingPageRoute(
        email: state.uri.queryParameters['email']!,
      );

  EmailConfirmationPendingPageRoute get _self =>
      this as EmailConfirmationPendingPageRoute;

  @override
  String get location => GoRouteData.$location(
    '/confirm-email',
    queryParams: {'email': _self.email},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $newChatDraftFlowRoute => GoRouteData.$route(
  path: '/chats/new-chat',
  hasOverriddenOnExit: false,
  factory: $NewChatDraftFlowRoute._fromState,
);

mixin $NewChatDraftFlowRoute on GoRouteData {
  static NewChatDraftFlowRoute _fromState(GoRouterState state) =>
      const NewChatDraftFlowRoute();

  @override
  String get location => GoRouteData.$location('/chats/new-chat');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $chatMessagesPageRoute => GoRouteData.$route(
  path: '/chats/chat-messages',
  hasOverriddenOnExit: false,
  factory: $ChatMessagesPageRoute._fromState,
);

mixin $ChatMessagesPageRoute on GoRouteData {
  static ChatMessagesPageRoute _fromState(GoRouterState state) =>
      ChatMessagesPageRoute(
        chatId: state.uri.queryParameters['chat-id']!,
        initialTitle: state.uri.queryParameters['initial-title'],
      );

  ChatMessagesPageRoute get _self => this as ChatMessagesPageRoute;

  @override
  String get location => GoRouteData.$location(
    '/chats/chat-messages',
    queryParams: {
      'chat-id': _self.chatId,
      if (_self.initialTitle != null) 'initial-title': _self.initialTitle,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $addNewPostPageRoute => GoRouteData.$route(
  path: '/add-new-post',
  hasOverriddenOnExit: false,
  factory: $AddNewPostPageRoute._fromState,
);

mixin $AddNewPostPageRoute on GoRouteData {
  static AddNewPostPageRoute _fromState(GoRouterState state) =>
      const AddNewPostPageRoute();

  @override
  String get location => GoRouteData.$location('/add-new-post');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $postViewerPageRoute => GoRouteData.$route(
  path: '/post-viewer',
  hasOverriddenOnExit: false,
  factory: $PostViewerPageRoute._fromState,
);

mixin $PostViewerPageRoute on GoRouteData {
  static PostViewerPageRoute _fromState(GoRouterState state) =>
      PostViewerPageRoute(postId: state.uri.queryParameters['post-id']!);

  PostViewerPageRoute get _self => this as PostViewerPageRoute;

  @override
  String get location => GoRouteData.$location(
    '/post-viewer',
    queryParams: {'post-id': _self.postId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileNameOnboardingPageRoute => GoRouteData.$route(
  path: '/onboarding/profile-name',
  hasOverriddenOnExit: false,
  factory: $ProfileNameOnboardingPageRoute._fromState,
);

mixin $ProfileNameOnboardingPageRoute on GoRouteData {
  static ProfileNameOnboardingPageRoute _fromState(GoRouterState state) =>
      const ProfileNameOnboardingPageRoute();

  @override
  String get location => GoRouteData.$location('/onboarding/profile-name');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRouteData => StatefulShellRouteData.$route(
  factory: $AppShellRouteDataExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/',
          hasOverriddenOnExit: false,
          factory: $PostsPageRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/chats',
          hasOverriddenOnExit: false,
          factory: $ChatsPageRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $AppShellRouteDataExtension on AppShellRouteData {
  static AppShellRouteData _fromState(GoRouterState state) =>
      const AppShellRouteData();
}

mixin $PostsPageRoute on GoRouteData {
  static PostsPageRoute _fromState(GoRouterState state) =>
      const PostsPageRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ChatsPageRoute on GoRouteData {
  static ChatsPageRoute _fromState(GoRouterState state) =>
      const ChatsPageRoute();

  @override
  String get location => GoRouteData.$location('/chats');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
