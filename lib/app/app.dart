import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/app_router.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_theme.dart';

/// Root widget for the application.
///
/// This widget wires together the global Material configuration, app theme,
/// and the central router used for all navigation and auth-based redirects.
class SocialApp extends StatelessWidget {
  /// Creates a [SocialApp].
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppUserCubit, AppUserState>(
      listener: (context, state) => AppRouter.router.refresh(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Social App',
        theme: AppTheme.darkThemeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
