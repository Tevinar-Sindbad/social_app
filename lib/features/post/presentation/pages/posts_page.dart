import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/blocs/post_list/post_list_bloc.dart';
import 'package:social_app/features/post/presentation/widgets/post_card.dart';
import 'package:social_app/features/post/presentation/widgets/post_card_place_holder.dart';

/// Page that displays the scrollable post list.
class PostsPage extends StatefulWidget {
  /// Creates a [PostsPage].
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late final ScrollController _postListScrollController;

  @override
  void initState() {
    super.initState();
    _postListScrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _postListScrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocConsumer<AppUserCubit, AppUserState>(
            listener: (_, state) => _onAppUserStateChanged(context, state),
            builder: (_, state) => _buildAppUserAction(context, state),
          ),
        ],
        title: Text(
          'Social App',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'posts-fab',
        onPressed: () => _openAddPostPage(context),
        tooltip: 'Create post',
        backgroundColor: AppPallete.primaryGreen,
        foregroundColor: AppPallete.primaryBackgroundColor,
        child: const Icon(Icons.edit_outlined),
      ),
      body: BlocConsumer<PostListBloc, PostListState>(
        listenWhen: (previous, current) =>
            previous.refreshError != current.refreshError &&
            current.refreshError != null,
        listener: (context, state) {
          if (state.refreshError != null) {
            showSnackBar(context, state.refreshError!);
          }
        },
        builder: (_, state) => _buildBody(context, state),
      ),
    );
  }

  Widget _buildAppUserAction(BuildContext context, AppUserState state) {
    if (state is AppUserLoading) {
      return const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Loader(size: 20),
      );
    }

    return IconButton(
      onPressed: () => _signOut(context),
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout, size: 24),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AppUserCubit>().signOut();
  }

  void _onAppUserStateChanged(BuildContext context, AppUserState state) {
    if (state is AppUserFailure) {
      showSnackBar(context, state.error);
    }
  }

  Future<void> _openAddPostPage(BuildContext context) async {
    final postListBloc = context.read<PostListBloc>();
    final createdPost = await const AddNewPostPageRoute().push<Post>(context);

    if (createdPost == null) {
      return;
    }

    postListBloc.add(PrependCreatedPost(createdPost));
    await _scrollToTop();
  }

  Widget _buildBody(BuildContext context, PostListState state) {
    if (state is PostListLoading && state.posts.isEmpty) {
      return _buildLoadingPlaceholders();
    }

    if (state is PostListFailure && state.posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(state.error),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<PostListBloc>().add(const RefreshList());
            },
            child: _buildPostsList(context, state),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingPlaceholders() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          4,
          (index) => const PostCardPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, PostListState state) {
    if (state.posts.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      controller: _postListScrollController,
      itemCount: _itemCount(state),
      itemBuilder: (context, index) => _buildPostListItem(state, index),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'There are no posts to display. Start a new one!',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildPostListItem(PostListState state, int index) {
    if (index == state.posts.length) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Loader(size: 30)),
      );
    }

    return PostCard(
      post: state.posts[index],
    );
  }

  int _itemCount(PostListState state) {
    final isLoadingMore = state is PostListLoading && state.posts.isNotEmpty;

    return state.posts.length + (isLoadingMore ? 1 : 0);
  }

  /// Triggers post-list pagination when the user scrolls near the bottom of
  /// the mounted list.
  void _handleScroll() {
    // Abort until the scroll controller is attached to a list view.
    if (!_postListScrollController.hasClients) {
      return;
    }

    // Abort unless the user is near the bottom of the list. Also ignore
    // transient overscroll positions outside the valid scroll range.
    if (_postListScrollController.position.outOfRange ||
        _postListScrollController.offset <
            _postListScrollController.position.maxScrollExtent - 200) {
      return;
    }

    // Request the next cursor-based post slice once the bottom threshold is
    // reached.
    context.read<PostListBloc>().add(const LoadMoreList());
  }

  /// Smoothly scrolls the current mounted post list back to the top.
  Future<void> _scrollToTop() async {
    // Abort until the scroll controller is attached to a list view.
    if (!_postListScrollController.hasClients) {
      return;
    }

    // Animate the viewport back to the first visible post after a successful
    // prepend at the top of the feed.
    await _postListScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
