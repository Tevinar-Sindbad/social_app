import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/usecases/create_profile_name_use_case.dart';
import 'package:social_app/features/profile/presentation/bloc/profile_name_onboarding_bloc.dart';

class MockCreateProfileNameUseCase extends Mock
    implements CreateProfileNameUseCase {}

void main() {
  late MockCreateProfileNameUseCase createProfileNameUseCase;

  setUp(() {
    createProfileNameUseCase = MockCreateProfileNameUseCase();
  });

  blocTest<ProfileNameOnboardingBloc, ProfileNameOnboardingState>(
    'emits loading then success when profile-name creation succeeds',
    build: () {
      when(
        () => createProfileNameUseCase('Alice'),
      ).thenAnswer(
        (_) async => right(
          const Profile(id: 'user-1', name: 'Alice'),
        ),
      );

      return ProfileNameOnboardingBloc(
        createProfileNameUseCase: createProfileNameUseCase,
      );
    },
    act: (bloc) => bloc.add(
      ProfileNameOnboardingSubmit(name: 'Alice'),
    ),
    expect: () => [
      isA<ProfileNameOnboardingLoading>(),
      isA<ProfileNameOnboardingSuccess>(),
    ],
    verify: (_) {
      verify(() => createProfileNameUseCase('Alice')).called(1);
    },
  );

  blocTest<ProfileNameOnboardingBloc, ProfileNameOnboardingState>(
    'emits loading then failure when profile-name creation fails',
    build: () {
      when(
        () => createProfileNameUseCase('Alice'),
      ).thenAnswer(
        (_) async => left(
          const ValidationFailure('Please enter a valid profile name.'),
        ),
      );

      return ProfileNameOnboardingBloc(
        createProfileNameUseCase: createProfileNameUseCase,
      );
    },
    act: (bloc) => bloc.add(
      ProfileNameOnboardingSubmit(name: 'Alice'),
    ),
    expect: () => [
      isA<ProfileNameOnboardingLoading>(),
      isA<ProfileNameOnboardingFailure>().having(
        (state) => state.message,
        'message',
        'Please enter a valid profile name.',
      ),
    ],
  );
}
