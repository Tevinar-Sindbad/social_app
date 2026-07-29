import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/profile/domain/entities/profile.dart';
import 'package:social_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_app/features/profile/domain/usecases/create_profile_name_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository profileRepository;
  late CreateProfileNameUseCase useCase;

  setUp(() {
    profileRepository = MockProfileRepository();
    useCase = CreateProfileNameUseCase(profileRepository: profileRepository);
  });

  test(
    'given surrounding spaces when call is executed then trims the name '
    'before delegating to the repository',
    () async {
      const profile = Profile(id: 'user-1', name: 'Alice');
      when(
        () => profileRepository.createProfileName(name: 'Alice'),
      ).thenAnswer((_) async => right(profile));

      final result = await useCase('  Alice  ');

      expect(result.isRight(), isTrue);
      verify(
        () => profileRepository.createProfileName(name: 'Alice'),
      ).called(1);
    },
  );

  test(
    'given a repository failure when call is executed then returns it'
    ' unchanged',
    () async {
      const failure = ValidationFailure('Please enter a valid profile name.');
      when(
        () => profileRepository.createProfileName(name: 'Alice'),
      ).thenAnswer((_) async => left(failure));

      final result = await useCase('Alice');

      result.fold(
        (error) => expect(error, failure),
        (_) => fail('Expected a failure result'),
      );
    },
  );
}
