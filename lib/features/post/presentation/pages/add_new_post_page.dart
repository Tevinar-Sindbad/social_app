import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/media/image_picker.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/post/domain/value_objects/post_topic.dart';
import 'package:social_app/features/post/presentation/blocs/post_editor/post_editor_bloc.dart';
import 'package:social_app/features/post/presentation/widgets/post_editor.dart';

/// Page that allows the user to add a new post.
class AddNewPostPage extends StatefulWidget {
  /// Creates a [AddNewPostPage].
  const AddNewPostPage({super.key});

  @override
  State<AddNewPostPage> createState() => _AddNewPostPageState();
}

class _AddNewPostPageState extends State<AddNewPostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<PostTopic> selectedTopics = [];
  File? image;
  bool _isImagePickerLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New post',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 20),
                  _buildTopicsSelector(),
                  const SizedBox(height: 10),
                  PostEditor(
                    controller: titleController,
                    hintText: 'Title',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  PostEditor(
                    controller: contentController,
                    hintText: 'Content',
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 20),
                  _buildBlocAction(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlocAction() {
    return BlocConsumer<PostEditorBloc, PostEditorState>(
      listener: (context, state) {
        if (state is PostFailure) {
          showSnackBar(context, state.error);
        } else if (state is PostUploadSuccess) {
          context.pop(state.post);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is PostLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSubmitting ? null : _uploadPost,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: AppPallete.primaryGreen,
              foregroundColor: AppPallete.primaryBackgroundColor,
            ),
            icon: isSubmitting ? null : const Icon(Icons.publish_rounded),
            label: isSubmitting
                ? const Loader(
                    size: 20,
                    color: AppPallete.primaryBackgroundColor,
                  )
                : Text(
                    'Publish post',
                    style:
                        Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          color: AppPallete.primaryBackgroundColor,
                        ),
                  ),
          ),
        );
      },
    );
  }

  void _uploadPost() {
    if (image == null) {
      showSnackBar(context, 'Please select an image');
      return;
    }
    if (selectedTopics.isEmpty) {
      showSnackBar(context, 'Please select at least one topic');
      return;
    }
    if (!formKey.currentState!.validate()) {
      return;
    }
    final state = context.read<AppUserCubit>().state;
    if (state is! AppUserSignedIn) {
      showSnackBar(context, 'You must be signed in to add a post');
      return;
    }

    context.read<PostEditorBloc>().add(
      AddPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        topics: selectedTopics,
        image: image!,
      ),
    );
  }

  Widget _buildImageSection() {
    if (image != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _selectImage,
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _isImagePickerLoading
                  ? const Center(child: Loader())
                  : Image.file(
                      image!,
                      fit: BoxFit.cover,
                      semanticLabel: 'Selected post image preview',
                    ),
            ),
          ),
        ),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _selectImage,
          child: DottedBorder(
            options: const RoundedRectDottedBorderOptions(
              dashPattern: [10, 4],
              color: AppPallete.secondaryBackgroundColor,
              radius: Radius.circular(10),
              strokeCap: StrokeCap.round,
            ),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: _isImagePickerLoading
                  ? const Center(child: Loader())
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 40),
                        SizedBox(height: 15),
                        Text(
                          'Pick image',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Opens the photo library',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTopicsSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PostTopic.values
          .map(
            (topic) => FilterChip(
              label: Text(
                topic.value,
                style: const TextStyle(color: AppPallete.textPrimary),
              ),
              selected: selectedTopics.contains(topic),
              selectedColor: AppPallete.primaryGreenMuted,
              checkmarkColor: AppPallete.textPrimary,
              side: BorderSide(
                color: selectedTopics.contains(topic)
                    ? AppPallete.primaryGreenMuted
                    : AppPallete.secondaryBackgroundColor,
              ),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedTopics.add(topic);
                  } else {
                    selectedTopics.remove(topic);
                  }
                });
              },
            ),
          )
          .toList(),
    );
  }

  Future<void> _selectImage() async {
    if (_isImagePickerLoading) return;

    setState(() {
      _isImagePickerLoading = true;
    });

    try {
      final pickedImage = await pickImageFromGallery();

      if (!mounted) return;

      if (pickedImage != null) {
        setState(() {
          image = pickedImage;
        });
      }
    } on Exception {
      if (mounted) {
        showSnackBar(context, 'Failed to pick image');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImagePickerLoading = false;
        });
      }
    }
  }
}
