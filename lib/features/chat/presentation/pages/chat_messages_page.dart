import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/app/session/signed_in_app_user.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_message_list/chat_message_list_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_session/chat_session_bloc.dart';
import 'package:social_app/features/chat/presentation/formatting/format_chat_title.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_message_card.dart';

/// Page that displays the messages of a chat session and allows sending new
/// messages.
class ChatMessagesPage extends StatefulWidget {
  /// Creates a [ChatMessagesPage].
  const ChatMessagesPage({
    this.chatId,
    this.initialTitle,
    this.onBackPressed,
    // Allows callers to opt into a fresh page instance when they need
    // isolated controller and scroll state for a distinct chat entry.
    super.key,
  });

  /// Existing chat identifier used to bootstrap the page from the chats list.
  final String? chatId;

  /// Best-effort title shown while an existing chat is still bootstrapping.
  final String? initialTitle;

  /// Callback used by flow owners to override the default back behavior.
  final VoidCallback? onBackPressed;

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late final TextEditingController _messageController;
  late final ScrollController _messageListScrollController;
  ChatMessageListBloc? _chatMessageListBloc;

  // Snapshot captured before loading older messages so the viewport can be
  // restored after the prepend completes.
  _PendingOlderMessagesRestore? _pendingOlderMessagesRestore;

  // Last rendered message count, used to detect whether the current state
  // added new items compared with the previous one.
  int _previousMessageCount = 0;

  // Tracks whether the initial "open at the newest message" positioning has
  // already been performed for the current mounted chat page.
  bool _hasInitializedMessageListScroll = false;

  // Forces the next state update that adds a message to scroll to the bottom
  // after the current user sends one.
  bool _shouldScrollToBottomAfterNextMessage = false;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _messageListScrollController = ScrollController()
      ..addListener(_handleMessageListScroll);
    _resolveExistingChatIfNeeded();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageListScrollController
      ..removeListener(_handleMessageListScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppUserCubit>().currentUser;

    return BlocConsumer<ChatSessionBloc, ChatSessionState>(
      listener: (context, state) {
        if (state is ChatSessionFailure) {
          showSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is! ChatSessionLoaded) {
          return _buildPage(context, state, currentUser);
        }

        return BlocProvider(
          key: ValueKey(state.chatId),
          create: (_) =>
              serviceLocator<ChatMessageListBloc>(param1: state.chatId),
          child: Builder(
            builder: (context) => _buildPage(context, state, currentUser),
          ),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    ChatSessionState chatEditorState,
    SignedInAppUser? currentUser,
  ) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              _handleBackPressed(context);
            },
          ),
        ),
        body: const Center(
          child: Text('Current user is unavailable.'),
        ),
      );
    }

    if (widget.chatId != null && chatEditorState is! ChatSessionLoaded) {
      if (chatEditorState is ChatSessionFailure) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                _handleBackPressed(context);
              },
            ),
            title: Text(
              widget.initialTitle ?? 'Chat',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          body: Center(
            child: Text(chatEditorState.message),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              _handleBackPressed(context);
            },
          ),
          title: Text(
            widget.initialTitle ?? 'Chat',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: const Center(
          child: Loader(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            _handleBackPressed(context);
          },
        ),
        title: Text(
          _chatTitle(chatEditorState, currentUser),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          _buildMessagesSection(chatEditorState, currentUser),
          _buildComposer(context, chatEditorState, currentUser),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(
    ChatSessionState chatEditorState,
    SignedInAppUser currentUser,
  ) {
    if (chatEditorState is! ChatSessionLoaded) {
      return const Expanded(child: SizedBox());
    }

    return Expanded(
      child: BlocConsumer<ChatMessageListBloc, ChatMessageListState>(
        listener: (context, chatMessagesState) {
          _handleChatMessageListStateChanged(chatMessagesState);
        },
        builder: (context, chatMessagesState) {
          _chatMessageListBloc = context.read<ChatMessageListBloc>();
          final shouldHideMessagesUntilInitialScroll =
              !_hasInitializedMessageListScroll &&
              chatMessagesState.chatMessages.isNotEmpty;

          return Opacity(
            opacity: shouldHideMessagesUntilInitialScroll ? 0 : 1,
            child: ListView.builder(
              controller: _messageListScrollController,
              itemCount: _messageItemCount(chatMessagesState),
              itemBuilder: (context, index) {
                return _buildChatMessageListItem(
                  chatMessagesState,
                  index,
                  currentUser,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatMessageListItem(
    ChatMessageListState chatMessagesState,
    int index,
    SignedInAppUser currentUser,
  ) {
    final hasLoadingMoreIndicator = _hasLoadingMoreIndicator(chatMessagesState);

    if (hasLoadingMoreIndicator && index == 0) {
      return const Center(child: Loader(size: 30));
    }

    final messageIndex = hasLoadingMoreIndicator ? index - 1 : index;
    final currentChatMessage = chatMessagesState.chatMessages[messageIndex];

    return Column(
      children: [
        if (_shouldShowDateSeparator(chatMessagesState, messageIndex))
          _buildDateSeparator(currentChatMessage.createdAt),
        ChatMessageCard(
          chatMessage: currentChatMessage,
          authorName: _authorName(currentChatMessage),
          isMe: currentChatMessage.author?.id == currentUser.id,
        ),
      ],
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        formatToDay(date),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildComposer(
    BuildContext context,
    ChatSessionState state,
    SignedInAppUser currentUser,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          spacing: 5,
          children: [
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            _buildSendButton(context, state, currentUser),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    ChatSessionState state,
    SignedInAppUser currentUser,
  ) {
    final canSendMessage = _canSendMessage(state);

    return IconButton.filled(
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          AppPallete.primaryGreen,
        ),
      ),
      onPressed: state is ChatSessionLoading || !canSendMessage
          ? null
          : () => _sendMessage(context, state, currentUser),
      tooltip: 'Send message',
      icon: state is ChatSessionLoading
          ? const Loader(
              color: AppPallete.primaryBackgroundColor,
              size: 26,
            )
          : const Icon(
              Icons.send,
              color: AppPallete.primaryBackgroundColor,
              size: 26,
            ),
    );
  }

  /// Bootstraps the shared chat-session bloc when this page opens an existing
  /// chat directly from the chats list.
  void _resolveExistingChatIfNeeded() {
    final chatId = widget.chatId;

    if (chatId != null) {
      context.read<ChatSessionBloc>().add(
        OpenChatById(chatId: chatId),
      );
    }
  }

  String _chatTitle(
    ChatSessionState chatEditorState,
    SignedInAppUser currentUser,
  ) {
    return formatChatTitleFromMembers(
      chatEditorState.chatMembers,
      currentUserId: currentUser.id,
    );
  }

  int _messageItemCount(ChatMessageListState chatMessagesState) {
    return chatMessagesState.chatMessages.length +
        (_hasLoadingMoreIndicator(chatMessagesState) ? 1 : 0);
  }

  String _authorName(ChatMessage chatMessage) {
    return chatMessage.author?.name ?? 'Unknown user';
  }

  bool _shouldShowDateSeparator(
    ChatMessageListState chatMessagesState,
    int messageIndex,
  ) {
    if (messageIndex == 0) {
      return true;
    }

    final currentChatMessage = chatMessagesState.chatMessages[messageIndex];
    final previousChatMessage =
        chatMessagesState.chatMessages[messageIndex - 1];

    return !_isSameDay(
      currentChatMessage.createdAt,
      previousChatMessage.createdAt,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasLoadingMoreIndicator(ChatMessageListState chatMessagesState) {
    return chatMessagesState is ChatMessageListLoading &&
        chatMessagesState.chatMessages.isNotEmpty;
  }

  /// Reacts to message-list state changes and keeps scroll behavior coherent.
  void _handleChatMessageListStateChanged(ChatMessageListState state) {
    // Older messages were requested from the top of the list, so restore the
    // previous viewport position after the prepend completes.
    if (_pendingOlderMessagesRestore != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollAfterOlderMessagesPrepended(state);
      });
      _previousMessageCount = state.chatMessages.length;
      return;
    }

    // The first resolved slice has just arrived, so place the viewport at the
    // newest message before showing the list at full opacity.
    if (!_hasInitializedMessageListScroll && state.chatMessages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeResolvedChatScroll();
      });
      _previousMessageCount = state.chatMessages.length;
      return;
    }

    final shouldAutoScrollToBottom =
        _shouldScrollToBottomAfterNextMessage || _isNearBottom();

    // New messages were added after initialization. Keep the user pinned to
    // the newest content only when they were already near the bottom or just
    // sent a message themselves.
    if (state.chatMessages.length > _previousMessageCount &&
        shouldAutoScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    _previousMessageCount = state.chatMessages.length;
  }

  /// Triggers older-message pagination when the user scrolls near the top of
  /// an initialized loaded chat list.
  void _handleMessageListScroll() {
    // Abort until the initial bottom positioning has run, while no live
    // scrollable is attached, or while a previous older-message restore cycle
    // is still pending.
    if (!_hasInitializedMessageListScroll ||
        !_messageListScrollController.hasClients ||
        _pendingOlderMessagesRestore != null) {
      return;
    }

    final chatMessageListBloc = _chatMessageListBloc;

    // Abort when the descendant message-list bloc is not available yet from
    // the currently mounted loaded-chat subtree.
    if (chatMessageListBloc == null) {
      return;
    }

    final chatMessageListState = chatMessageListBloc.state;

    // Abort while an older-message request is already loading, when the list
    // is still empty, or when the backend has no next cursor left to load.
    if (chatMessageListState is ChatMessageListLoading ||
        chatMessageListState.chatMessages.isEmpty ||
        chatMessageListState.nextCursor == null) {
      return;
    }

    // Abort unless the user is truly near the top of the list. Also ignore
    // out-of-range positions produced by transient overscroll.
    if (_messageListScrollController.position.outOfRange ||
        _messageListScrollController.offset > 200) {
      return;
    }

    // Capture the current viewport before prepending older messages so the
    // same content can stay under the user’s eyes after loading completes.
    _pendingOlderMessagesRestore = _PendingOlderMessagesRestore(
      previousMessageCount: chatMessageListState.chatMessages.length,
      previousMaxScrollExtent:
          _messageListScrollController.position.maxScrollExtent,
      previousScrollOffset: _messageListScrollController.offset,
    );

    // Request the next older slice now that the user has reached the top
    // pagination threshold.
    chatMessageListBloc.add(
      const LoadChatMessageListNextSlice(),
    );
  }

  /// Restores the previous viewport position after older messages are
  /// prepended at the top of the list.
  void _restoreScrollAfterOlderMessagesPrepended(ChatMessageListState state) {
    final pendingOlderMessagesRestore = _pendingOlderMessagesRestore;

    // Abort if there is no pending restore request anymore or if the list is
    // no longer attached to a live scroll position.
    if (pendingOlderMessagesRestore == null ||
        !_messageListScrollController.hasClients) {
      return;
    }

    // Wait until loading has finished because the final scroll extent is still
    // unstable while the prepend request is in flight.
    if (state is ChatMessageListLoading) {
      return;
    }

    // Restore the previous reading position only when older items were
    // actually inserted ahead of the current viewport.
    if (state.chatMessages.length >
        pendingOlderMessagesRestore.previousMessageCount) {
      final nextOffset =
          pendingOlderMessagesRestore.previousScrollOffset +
          (_messageListScrollController.position.maxScrollExtent -
              pendingOlderMessagesRestore.previousMaxScrollExtent);

      _messageListScrollController.jumpTo(
        nextOffset.clamp(
          0,
          _messageListScrollController.position.maxScrollExtent,
        ),
      );
    }

    _pendingOlderMessagesRestore = null;
    _hasInitializedMessageListScroll = true;
  }

  /// Positions the initially loaded chat at the newest message once the list
  /// has a resolved scroll extent.
  void _initializeResolvedChatScroll() {
    // Abort when the scrollable is not attached yet, when the initial
    // positioning already happened, or while an older-message restore cycle is
    // still pending.
    if (!_messageListScrollController.hasClients ||
        _hasInitializedMessageListScroll ||
        _pendingOlderMessagesRestore != null) {
      return;
    }

    // Open the resolved chat with the viewport pinned to the newest message.
    _messageListScrollController.jumpTo(
      _messageListScrollController.position.maxScrollExtent,
    );

    // Mark the initial positioning as completed and clear any forced
    // bottom-scroll request that is no longer relevant after initialization.
    setState(() {
      _hasInitializedMessageListScroll = true;
      _shouldScrollToBottomAfterNextMessage = false;
    });
  }

  void _scrollToBottom() {
    _shouldScrollToBottomAfterNextMessage = false;

    if (!_messageListScrollController.hasClients) {
      return;
    }

    _messageListScrollController.jumpTo(
      _messageListScrollController.position.maxScrollExtent,
    );
  }

  bool _isNearBottom() {
    if (!_messageListScrollController.hasClients) {
      return false;
    }

    return _messageListScrollController.position.maxScrollExtent -
            _messageListScrollController.offset <=
        24;
  }

  bool _canSendMessage(ChatSessionState state) {
    return state is ChatSessionLoaded ||
        state is ChatSessionWaitingForFirstMessage ||
        (state is ChatSessionFailure && widget.chatId == null);
  }

  void _handleBackPressed(BuildContext context) {
    final onBackPressed = widget.onBackPressed;
    if (onBackPressed != null) {
      onBackPressed();
      return;
    }

    context.pop();
  }

  void _sendMessage(
    BuildContext context,
    ChatSessionState state,
    SignedInAppUser currentUser,
  ) {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) {
      return;
    }

    if (state is ChatSessionLoaded) {
      _sendLoadedChatMessage(context, state.chatId, messageText, currentUser);
      return;
    }

    if (state is ChatSessionWaitingForFirstMessage ||
        (state is ChatSessionFailure && widget.chatId == null)) {
      _sendFirstChatMessage(context, messageText);
    }
  }

  void _sendLoadedChatMessage(
    BuildContext context,
    String chatId,
    String messageText,
    SignedInAppUser currentUser,
  ) {
    _shouldScrollToBottomAfterNextMessage = true;

    context.read<ChatMessageListBloc>().add(
      AddChatMessage(
        chatId: chatId,
        content: messageText,
        author: ChatUserSummary(id: currentUser.id, name: currentUser.name),
      ),
    );
    _messageController.clear();
  }

  void _sendFirstChatMessage(BuildContext context, String messageText) {
    context.read<ChatSessionBloc>().add(
      AddChatFirstMessage(firstMessageContent: messageText),
    );
    _messageController.clear();
  }
}

class _PendingOlderMessagesRestore {
  const _PendingOlderMessagesRestore({
    required this.previousMessageCount,
    required this.previousMaxScrollExtent,
    required this.previousScrollOffset,
  });

  final int previousMessageCount;
  final double previousMaxScrollExtent;
  final double previousScrollOffset;
}
