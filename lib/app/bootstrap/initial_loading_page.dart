import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/session/app_user_cubit.dart';

/// A initial loading page widget.
class InitialLoadingPage extends StatelessWidget {
  /// Creates a [InitialLoadingPage].
  const InitialLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            if (state is AppUserFailure) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Center(
              child: Image.asset(
                'assets/images/initial_loading_logo.png',
                height: 150,
                width: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}
