import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/app/session/signed_in_app_user.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_card.dart';

/// Page that displays a list of the user's chats.
class ChatsPage extends StatefulWidget {
  /// Creates a [ChatsPage].
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final ScrollController _chatListScrollController;

  @override
  void initState() {
    super.initState();
    _chatListScrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _chatListScrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppUserCubit>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) => _buildBody(context, state, currentUser),
        ),
      ),
      floatingActionButton: _buildNewChatButton(context),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatListState state,
    SignedInAppUser? currentUser,
  ) {
    if (currentUser == null) {
      return const Center(
        child: Text('Current user is unavailable.'),
      );
    }

    if (state is ChatListFailure) {
      return Center(
        child: Text('Error loading chats : ${state.error}'),
      );
    }

    // Show placeholders while the first page of chats is loading.
    if (state is ChatListLoading && state.chats.isEmpty) {
      return const Center(child: Loader());
    }

    if (state.chats.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildChatsList(context, state, currentUser.id);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        "You don't have any chats. Start a new one!",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildChatsList(
    BuildContext context,
    ChatListState state,
    String currentUserId,
  ) {
    return ListView.builder(
      controller: _chatListScrollController,
      itemCount: _chatItemCount(state),
      itemBuilder: (context, index) =>
          _buildChatListItem(state, index, currentUserId),
    );
  }

  Widget _buildChatListItem(
    ChatListState state,
    int index,
    String currentUserId,
  ) {
    if (index == state.chats.length) {
      return const Center(child: Loader(size: 30));
    }

    return ChatCard(
      chat: state.chats[index],
      currentUserId: currentUserId,
    );
  }

  int _chatItemCount(ChatListState state) {
    final isLoadingMore = state is ChatListLoading && state.chats.isNotEmpty;

    return state.chats.length + (isLoadingMore ? 1 : 0);
  }

  Widget _buildNewChatButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chats-fab',
      onPressed: () => const NewChatDraftFlowRoute().push<void>(context),
      tooltip: 'Start new chat',
      backgroundColor: AppPallete.primaryGreen,
      foregroundColor: AppPallete.primaryBackgroundColor,
      child: const Icon(Icons.add_box_rounded),
    );
  }

  /// Triggers chat-list pagination when the user scrolls near the bottom of
  /// the mounted list.
  void _handleScroll() {
    // Abort until the scroll controller is attached to a live list view.
    if (!_chatListScrollController.hasClients) {
      return;
    }

    // Abort unless the user is near the bottom of the list. Also ignore
    // transient overscroll positions outside the valid scroll range.
    if (_chatListScrollController.position.outOfRange ||
        _chatListScrollController.offset <
            _chatListScrollController.position.maxScrollExtent - 200) {
      return;
    }

    // Request the next cursor-based chat slice once the bottom threshold is
    // reached.
    context.read<ChatListBloc>().add(const LoadChatListNextSlice());
  }
}
