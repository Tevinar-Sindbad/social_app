import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/usecases/create_profile_name_use_case.dart';
import 'package:social_app/features/profile/presentation/bloc/profile_name_onboarding_bloc.dart';
import 'package:social_app/features/profile/presentation/pages/profile_name_onboarding_page.dart';

class MockCreateProfileNameUseCase extends Mock
    implements CreateProfileNameUseCase {}

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

void main() {
  late MockCreateProfileNameUseCase createProfileNameUseCase;
  late MockAppUserCubit appUserCubit;

  setUp(() async {
    createProfileNameUseCase = MockCreateProfileNameUseCase();
    appUserCubit = MockAppUserCubit();

    when(() => appUserCubit.state).thenReturn(AppUserSignedOut());
    when(() => appUserCubit.refreshCurrentUser()).thenAnswer((_) async {});

    await serviceLocator.reset();
    serviceLocator.registerFactory(
      () => ProfileNameOnboardingBloc(
        createProfileNameUseCase: createProfileNameUseCase,
      ),
    );
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  group('ProfileNameOnboardingPage', () {
    testWidgets('renders the expected onboarding copy and controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(appUserCubit: appUserCubit),
      );

      expect(find.text('Choose your name.'), findsOneWidget);
      expect(find.text('Profile name'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets(
      'given an empty name when continue is tapped then shows validation and '
      'does not submit',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(appUserCubit: appUserCubit),
        );

        await tester.tap(find.text('Continue'));
        await tester.pump();

        expect(find.text('Profile name is missing!'), findsOneWidget);
        verifyNever(() => createProfileNameUseCase(any()));
      },
    );

    testWidgets(
      'given a pending submission when continue is tapped then shows the '
      ' loader',
      (tester) async {
        final completer = Completer<Either<Failure, Profile>>();
        when(
          () => createProfileNameUseCase('Alice'),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(
          _buildTestApp(appUserCubit: appUserCubit),
        );

        await tester.enterText(find.byType(TextFormField), 'Alice');
        await tester.tap(find.text('Continue'));
        await tester.pump();

        expect(find.byType(Loader), findsOneWidget);
        expect(find.byType(ProfileNameOnboardingPage), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
      },
    );

    testWidgets(
      'given a failed submission when continue is tapped then shows a snackbar',
      (tester) async {
        when(
          () => createProfileNameUseCase('Alice'),
        ).thenAnswer(
          (_) async => left(
            const ValidationFailure('Please enter a valid profile name.'),
          ),
        );

        await tester.pumpWidget(
          _buildTestApp(appUserCubit: appUserCubit),
        );

        await tester.enterText(find.byType(TextFormField), 'Alice');
        await tester.tap(find.text('Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Please enter a valid profile name.'), findsOneWidget);
      },
    );

    testWidgets(
      'given a successful submission when continue is tapped then refreshes the'
      ' global app user',
      (tester) async {
        when(
          () => createProfileNameUseCase('Alice'),
        ).thenAnswer(
          (_) async => right(
            const Profile(id: 'user-1', name: 'Alice'),
          ),
        );

        await tester.pumpWidget(
          _buildTestApp(appUserCubit: appUserCubit),
        );

        await tester.enterText(find.byType(TextFormField), 'Alice');
        await tester.tap(find.text('Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        verify(() => appUserCubit.refreshCurrentUser()).called(1);
      },
    );
  });
}

Widget _buildTestApp({required AppUserCubit appUserCubit}) {
  return BlocProvider<AppUserCubit>.value(
    value: appUserCubit,
    child: const MaterialApp(
      home: ProfileNameOnboardingPage(),
    ),
  );
}
