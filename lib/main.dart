import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:social_app/app/app.dart';
import 'package:social_app/app/bootstrap/configure_global_error_handling.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/bootstrap/init_sentry.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/config/env_variables.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSentry(() async {
    configureGlobalErrorHandling();
    await Supabase.initialize(
      url: EnvVariables.supabaseUrl,
      publishableKey: EnvVariables.supabasePublishableKey,
    );

    await initDependencies();

    runApp(
      SentryWidget(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
            BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
          ],
          child: const SocialApp(),
        ),
      ),
    );
  });
}
