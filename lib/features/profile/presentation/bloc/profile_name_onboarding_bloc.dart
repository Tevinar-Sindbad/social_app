import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/domain/usecases/create_profile_name_use_case.dart';

part 'profile_name_onboarding_event.dart';
part 'profile_name_onboarding_state.dart';

/// Feature BLoC responsible for the profile-name onboarding submission flow.
class ProfileNameOnboardingBloc
    extends Bloc<ProfileNameOnboardingEvent, ProfileNameOnboardingState> {
  /// Creates a [ProfileNameOnboardingBloc].
  ProfileNameOnboardingBloc({
    required CreateProfileNameUseCase createProfileNameUseCase,
  }) : _createProfileNameUseCase = createProfileNameUseCase,
       super(ProfileNameOnboardingIdle()) {
    on<ProfileNameOnboardingSubmit>(_onSubmit);
  }

  final CreateProfileNameUseCase _createProfileNameUseCase;

  Future<void> _onSubmit(
    ProfileNameOnboardingSubmit event,
    Emitter<ProfileNameOnboardingState> emit,
  ) async {
    emit(ProfileNameOnboardingLoading());

    final result = await _createProfileNameUseCase(event.name);

    result.fold(
      (failure) => emit(ProfileNameOnboardingFailure(failure.message)),
      (_) => emit(ProfileNameOnboardingSuccess()),
    );
  }
}
