import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/core/ui/widgets/required_text_form_field.dart';
import 'package:social_app/features/profile/presentation/bloc/profile_name_onboarding_bloc.dart';

/// Page that creates the first app-owned profile name after authentication.
class ProfileNameOnboardingPage extends StatefulWidget {
  /// Creates a [ProfileNameOnboardingPage].
  const ProfileNameOnboardingPage({super.key});

  @override
  State<ProfileNameOnboardingPage> createState() =>
      _ProfileNameOnboardingPageState();
}

class _ProfileNameOnboardingPageState extends State<ProfileNameOnboardingPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<ProfileNameOnboardingBloc>(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: _buildPageBody(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    return BlocListener<ProfileNameOnboardingBloc, ProfileNameOnboardingState>(
      listener: _onBlocStateChanged,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: _buildFormContent(context),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Choose your name.',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'This is the public profile name shown inside the app.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        RequiredTextFormField(
          labelText: 'Profile name',
          controller: _nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.nickname],
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<ProfileNameOnboardingBloc, ProfileNameOnboardingState>(
        builder: (context, state) {
          final isSubmitting = state is ProfileNameOnboardingLoading;

          return ElevatedButton(
            onPressed: isSubmitting ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: AppPallete.primaryGreen,
              foregroundColor: AppPallete.primaryBackgroundColor,
            ),
            child: isSubmitting
                ? const Loader(
                    size: 20,
                    color: AppPallete.primaryBackgroundColor,
                  )
                : Text(
                    'Continue',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppPallete.primaryBackgroundColor,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Future<void> _onBlocStateChanged(
    BuildContext context,
    ProfileNameOnboardingState state,
  ) async {
    if (state is ProfileNameOnboardingFailure) {
      showSnackBar(context, state.message);
      return;
    }

    if (state is ProfileNameOnboardingSuccess) {
      await context.read<AppUserCubit>().refreshCurrentUser();
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileNameOnboardingBloc>().add(
      ProfileNameOnboardingSubmit(
        name: _nameController.text,
      ),
    );
  }
}
