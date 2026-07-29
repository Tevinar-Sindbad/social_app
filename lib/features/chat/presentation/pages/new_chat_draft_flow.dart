import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_session/chat_session_bloc.dart';
import 'package:social_app/features/chat/presentation/formatting/format_chat_title.dart';
import 'package:social_app/features/chat/presentation/pages/chat_candidates_page.dart';
import 'package:social_app/features/chat/presentation/pages/chat_messages_page.dart';

/// Hosts the local two-step draft chat flow.
class NewChatDraftFlow extends StatefulWidget {
  /// Creates a [NewChatDraftFlow].
  const NewChatDraftFlow({super.key});

  @override
  State<NewChatDraftFlow> createState() => _NewChatDraftFlowState();
}

class _NewChatDraftFlowState extends State<NewChatDraftFlow> {
  final GlobalKey<NavigatorState> _draftFlowNavigatorKey =
      GlobalKey<NavigatorState>();
  bool _isDraftComposerVisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatSessionBloc, ChatSessionState>(
      listener: _onChatSessionStateChanged,
      child: NavigatorPopHandler<void>(
        onPopWithResult: (_) => _handleDraftFlowBack(),
        child: Navigator(
          key: _draftFlowNavigatorKey,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => ChatCandidatesPage(
              onBackPressed: () {
                context.pop();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the local chat step once member selection resolves to a chat state.
  ///
  /// A new member set first resolves to [ChatSessionWaitingForFirstMessage],
  /// while an existing chat resolves directly to [ChatSessionLoaded]. Both
  /// cases should transition away from member selection into the shared chat
  /// page.
  void _onChatSessionStateChanged(
    BuildContext context,
    ChatSessionState state,
  ) {
    if (state is ChatSessionWaitingForFirstMessage ||
        state is ChatSessionLoaded) {
      unawaited(_pushChatMessagesStep());
    }
  }

  /// Pushes the local chat step on top of the member-selection step.
  ///
  /// This uses the nested [Navigator] instead of `go_router` because the draft
  /// composer is an internal step of the same full-screen flow, not a separate
  /// app-level route. Keeping both steps under the same local navigator lets
  /// them share the same [ChatSessionBloc] instance and keeps back navigation
  /// inside the draft flow until a real chat has been created.
  Future<void> _pushChatMessagesStep() async {
    if (_isDraftComposerVisible) {
      return;
    }

    final draftFlowNavigator = _draftFlowNavigatorKey.currentState;
    if (draftFlowNavigator == null) {
      return;
    }

    _isDraftComposerVisible = true;

    await draftFlowNavigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChatMessagesPage(
          onBackPressed: _handleDraftFlowBack,
          initialTitle: _resolveInitialTitle(
            context.read<ChatSessionBloc>().state.chatMembers,
          ),
        ),
      ),
    );

    _isDraftComposerVisible = false;
  }

  /// Pops the local draft composer step back to member selection.
  void _popDraftComposer() {
    _draftFlowNavigatorKey.currentState?.pop();
  }

  /// Applies state-aware back navigation for the draft flow.
  ///
  /// Before the first message is sent, back returns to member selection.
  /// After the draft resolves into a persisted chat, back exits the whole
  /// full-screen flow to the chats list.
  void _handleDraftFlowBack() {
    final state = context.read<ChatSessionBloc>().state;

    if (state is ChatSessionLoaded) {
      context.pop();
      return;
    }

    _popDraftComposer();
  }

  /// Builds the best-effort chat title used before the persisted chat header
  /// is fully resolved.
  String? _resolveInitialTitle(List<ChatUserSummary> chatMembers) {
    final currentUserId = context.read<AppUserCubit>().currentUser?.id;
    final title = formatChatTitleFromMembers(
      chatMembers,
      currentUserId: currentUserId,
      fallback: '',
    );

    return title.isEmpty ? null : title;
  }
}
