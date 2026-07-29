part of '../routes.dart';

/// Absolute path for the chats route.
const chatsRoutePath = '/chats';

/// Absolute path for the full-screen new-chat route.
const newChatRoutePath = '/chats/new-chat';

/// Absolute path for the full-screen chat-messages route.
const chatMessagesRoutePath = '/chats/chat-messages';

/// Root route for the chats tab inside the signed-in app shell.
///
/// The chats list owns its own [ChatListBloc], so the provider is created at
/// the route boundary instead of globally for the whole app.
class ChatsPageRoute extends GoRouteData with $ChatsPageRoute {
  /// Creates a [ChatsPageRoute].
  const ChatsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => serviceLocator<ChatListBloc>(),
      child: const ChatsPage(),
    );
  }
}

/// Route to the full-screen new-chat draft flow.
///
/// The route owns both the member-selection step and the draft composer step,
/// so their state survives local back navigation within the flow.
@TypedGoRoute<NewChatDraftFlowRoute>(path: newChatRoutePath)
class NewChatDraftFlowRoute extends GoRouteData with $NewChatDraftFlowRoute {
  /// Creates a [NewChatDraftFlowRoute].
  const NewChatDraftFlowRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<ChatSessionBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<ChatCandidateListBloc>(),
        ),
      ],
      child: const NewChatDraftFlow(),
    );
  }
}

/// Route to an existing chat messages screen.
///
/// Existing chats open through this independent full-screen route, which
/// recreates its [ChatSessionBloc] from the stable [chatId].
@TypedGoRoute<ChatMessagesPageRoute>(path: chatMessagesRoutePath)
class ChatMessagesPageRoute extends GoRouteData with $ChatMessagesPageRoute {
  /// Creates a [ChatMessagesPageRoute].
  const ChatMessagesPageRoute({required this.chatId, this.initialTitle});

  /// Existing chat identifier to bootstrap when opening from the chats list.
  final String chatId;

  /// Best-effort title shown while an existing chat is still bootstrapping.
  final String? initialTitle;

  @override
  Widget build(BuildContext context, GoRouterState state) => BlocProvider(
    create: (_) => serviceLocator<ChatSessionBloc>(),
    child: ChatMessagesPage(
      chatId: chatId,
      initialTitle: initialTitle,
    ),
  );
}
