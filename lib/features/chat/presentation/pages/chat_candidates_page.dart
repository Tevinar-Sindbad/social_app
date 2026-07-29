import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_candidates/chat_candidate_list_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_session/chat_session_bloc.dart';

/// Page that allows the user to select other users to start a new chat session
/// with.
class ChatCandidatesPage extends StatefulWidget {
  /// Creates a [ChatCandidatesPage].
  const ChatCandidatesPage({this.onBackPressed, super.key});

  /// Callback used by flow owners to override the default back behavior.
  final VoidCallback? onBackPressed;

  @override
  State<ChatCandidatesPage> createState() => _ChatCandidatesPageState();
}

class _ChatCandidatesPageState extends State<ChatCandidatesPage> {
  final List<ChatUserSummary> _selectedUsers = [];
  late final ScrollController _candidateListScrollController;

  @override
  void initState() {
    super.initState();
    _candidateListScrollController = ScrollController()
      ..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _candidateListScrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppUserCubit>().currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              _handleBackPressed(context);
            },
          ),
          title: const Text('New Chat'),
        ),
        body: const Center(
          child: Text('Current user is unavailable.'),
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
        title: const Text('New Chat'),
      ),
      body: BlocBuilder<ChatCandidateListBloc, ChatCandidateListState>(
        builder: (context, state) => _buildBody(context, state, currentUser.id),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatCandidateListState state,
    String currentUserId,
  ) {
    if (state is ChatCandidateListFailure) {
      return Center(
        child: Text('Error loading users : ${state.error}'),
      );
    }

    // Show placeholders while the first page of users is loading.
    if (state is ChatCandidateListLoading && state.candidates.isEmpty) {
      return const Center(child: Loader());
    }

    return _buildUsersList(context, state, currentUserId);
  }

  Widget _buildUsersList(
    BuildContext context,
    ChatCandidateListState state,
    String currentUserId,
  ) {
    if (state.candidates.isEmpty) {
      return Center(
        child: Text(
          'Nobody available to start a chat with.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      controller: _candidateListScrollController,
      itemCount: _userItemCount(state),
      itemBuilder: (context, index) =>
          _buildUserListItem(state, index, currentUserId),
    );
  }

  Widget _buildUserListItem(
    ChatCandidateListState state,
    int index,
    String currentUserId,
  ) {
    if (index == state.candidates.length) {
      return const Center(child: Loader(size: 30));
    }

    final user = state.candidates[index];

    if (_isCurrentUser(user, currentUserId)) {
      return const SizedBox.shrink();
    }

    return _buildUserSelectionTile(user);
  }

  bool _isCurrentUser(ChatUserSummary user, String currentUserId) {
    return user.id == currentUserId;
  }

  Widget _buildUserSelectionTile(ChatUserSummary user) {
    return CheckboxListTile(
      secondary: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.name),
      checkboxShape: const CircleBorder(),
      checkboxScaleFactor: 1.35,
      side: const BorderSide(
        width: 0.5,
        color: AppPallete.darkForegroundColor,
      ),
      checkColor: AppPallete.textPrimary,
      activeColor: AppPallete.primaryGreenMuted,
      value: _selectedUsers.contains(user),
      onChanged: (value) => _toggleUserSelection(user, value),
    );
  }

  void _toggleUserSelection(ChatUserSummary user, bool? value) {
    setState(() {
      if (value == true) {
        _selectedUsers.add(user);
      } else {
        _selectedUsers.remove(user);
      }
    });
  }

  int _userItemCount(ChatCandidateListState state) {
    final isLoadingMore =
        state is ChatCandidateListLoading && state.candidates.isNotEmpty;

    return isLoadingMore
        ? state.candidates.length + 1
        : state.candidates.length;
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedUsers.isEmpty) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<ChatSessionBloc, ChatSessionState>(
        listener: _onChatEditorStateChanged,
        builder: _buildCreateChatButton,
      ),
    );
  }

  void _onChatEditorStateChanged(
    BuildContext context,
    ChatSessionState state,
  ) {
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }

    if (state is ChatSessionFailure) {
      showSnackBar(context, state.message);
    }
  }

  Widget _buildCreateChatButton(BuildContext context, ChatSessionState state) {
    final isOpeningChat = state is ChatSessionLoading;

    return TextButton.icon(
      onPressed: isOpeningChat ? null : () => _startChat(context),
      label: _buildCreateChatButtonLabel(context, isOpeningChat),
      icon: _buildCreateChatButtonIcon(isOpeningChat),
      style: _createChatButtonStyle(),
    );
  }

  Widget _buildCreateChatButtonLabel(
    BuildContext context,
    bool isOpeningChat,
  ) {
    return Text(
      isOpeningChat ? 'Opening...' : 'Message',
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: AppPallete.primaryBackgroundColor,
      ),
    );
  }

  Widget _buildCreateChatButtonIcon(bool isOpeningChat) {
    if (isOpeningChat) {
      return const Loader(
        size: 18,
        color: AppPallete.primaryBackgroundColor,
      );
    }

    return const Icon(Icons.send, color: AppPallete.primaryBackgroundColor);
  }

  ButtonStyle _createChatButtonStyle() {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(
        AppPallete.primaryGreen,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(140, 50)),
    );
  }

  void _startChat(BuildContext context) {
    context.read<ChatSessionBloc>().add(
      AddChat(chatMembers: _selectedUsers),
    );
  }

  void _handleBackPressed(BuildContext context) {
    final onBackPressed = widget.onBackPressed;
    if (onBackPressed != null) {
      onBackPressed();
      return;
    }

    context.pop();
  }

  /// Triggers candidate-list pagination when the user scrolls near the bottom
  /// of the mounted list.
  void _handleScroll() {
    // Abort until the scroll controller is attached to a list view.
    if (!_candidateListScrollController.hasClients) {
      return;
    }

    // Abort unless the user is near the bottom of the list. Also ignore
    // transient overscroll positions outside the valid scroll range.
    if (_candidateListScrollController.position.outOfRange ||
        _candidateListScrollController.offset <
            _candidateListScrollController.position.maxScrollExtent - 200) {
      return;
    }

    // Request the next cursor-based candidate slice once the bottom threshold
    // is reached.
    context.read<ChatCandidateListBloc>().add(
      const LoadChatCandidateListNextSlice(),
    );
  }
}
