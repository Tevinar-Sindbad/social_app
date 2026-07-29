part of 'init_dependencies.dart';

/// The service locator.
final GetIt serviceLocator = GetIt.instance;

/// The init dependencies.
Future<void> initDependencies() async {
  _initDio();

  // app
  _initApp();

  // core
  _initCore();

  // features
  _initAuth();
  _initPost();
  _initChat();
  _initProfile();
}

/// Registers the application's HTTP clients.
///
/// We keep two separate `Dio` instances:
/// - `publicDio` for requests that must not require an access token
/// - `authedDio` for requests that automatically attach and refresh auth
///   credentials
void _initDio() {
  serviceLocator
    // Public client used for unauthenticated endpoints and third-party calls
    // that do not need an app access token.
    ..registerLazySingleton<Dio>(
      createPublicDio,
      instanceName: 'publicDio',
    )
    // Authenticated client used by protected feature APIs.
    ..registerLazySingleton<Dio>(
      () => createAuthedDio(
        authAccessTokenProvider: serviceLocator(),
      ),
      instanceName: 'authedDio',
    );
}

void _initApp() {
  serviceLocator
    // logging
    ..registerLazySingleton(createTalker)
    ..registerLazySingleton<AppTalkerLogger>(
      () => AppTalkerLogger(
        talker: serviceLocator(),
        appEnv: EnvVariables.appEnv,
      ),
    )
    ..registerLazySingleton(
      () => ClearSessionDataUseCase(
        clearPostCacheUseCase: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => AppUserCubit(
        clearCachedCurrentProfileUseCase: serviceLocator(),
        clearSessionDataUseCase: serviceLocator(),
        resolveCurrentProfileUseCase: serviceLocator(),
        userSignOut: serviceLocator(),
        watchAuthStateChanges: serviceLocator(),
      ),
    );
}

void _initCore() {
  // Connection checker
  serviceLocator
    ..registerLazySingleton(AppDatabase.new)
    ..registerLazySingleton(
      () => DioHttpDownloader(serviceLocator(instanceName: 'authedDio')),
    )
    ..registerLazySingleton<ImageFileCache>(
      () => ImageFileCacheImpl(
        dioHttpDownloader: serviceLocator(),
      ),
    );
}

void _initAuth() {
  serviceLocator
    ..registerLazySingleton(() => Supabase.instance.client)
    ..registerLazySingleton(
      () => AuthAccessTokenProvider(
        supabaseClient: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        logger: serviceLocator(),
        supabaseClient: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => UserSignUpUseCase(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ResendSignUpConfirmationEmailUseCase(
        authRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => UserSignInUseCase(authRepositoy: serviceLocator()),
    )
    ..registerLazySingleton(
      () => UserSignOutUseCase(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => WatchAuthStateChanges(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => WatchAuthFlowFailuresUseCase(authRepository: serviceLocator()),
    )
    // BLoC
    ..registerLazySingleton(
      () => AuthBloc(
        resendSignUpConfirmationEmailUseCase: serviceLocator(),
        userSignUpUseCase: serviceLocator(),
        userSignInUseCase: serviceLocator(),
        watchAuthFlowFailuresUseCase: serviceLocator(),
      ),
    );
}

void _initPost() {
  serviceLocator
    // Datasources
    ..registerLazySingleton<PostLocalDataSource>(
      () => PostLocalDataSourceDriftImpl(database: serviceLocator()),
    )
    ..registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(
        dio: serviceLocator(instanceName: 'authedDio'),
      ),
    )
    // Repositories
    ..registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        logger: serviceLocator(),
        postRemoteDataSource: serviceLocator(),
        postLocalDataSource: serviceLocator(),
        imageFileCache: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => ClearPostCacheUseCase(postRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => CreatePostUseCase(postRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetPostImageUseCase(postRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ObserveInitialPostListSliceUseCase(
        postRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => GetPostListSliceUseCase(postRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ObservePostByIdUseCase(serviceLocator()),
    )
    // BLoC
    ..registerFactory(() => PostEditorBloc(uploadPost: serviceLocator()))
    ..registerFactory(
      () => PostListBloc(
        observeInitialPostListSliceUseCase: serviceLocator(),
        getPostListSliceUseCase: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => PostViewerBloc(
        observePostByIdUseCase: serviceLocator(),
        getPostImageUseCase: serviceLocator(),
      ),
    );
}

void _initChat() {
  serviceLocator
    // Datasources
    ..registerLazySingleton(
      () => HttpSseClient(
        baseUrl: EnvVariables.backendBaseUrl,
        authAccessTokenProvider: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        dio: serviceLocator(instanceName: 'authedDio'),
        sseClient: serviceLocator(),
      ),
    )
    // Repositories
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        chatRemoteDataSource: serviceLocator(),
        logger: serviceLocator(),
      ),
    )
    // Usecases
    ..registerLazySingleton(
      () => CreateChatUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatMessageListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => CreateChatMessageUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatByMembersUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatByIdUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GetChatCandidateListSliceUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatListUseCase(chatRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => SubscribeToChatMessageListUseCase(chatRepository: serviceLocator()),
    )
    // BLoC
    ..registerFactory(
      () => ChatSessionBloc(
        createChat: serviceLocator(),
        getChatByMembers: serviceLocator(),
        getChatById: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatCandidateListBloc(
        getChatCandidateListSlice: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChatListBloc(
        getChatListSlice: serviceLocator(),
        subscribeToChatList: serviceLocator(),
      ),
    )
    ..registerFactoryParam<ChatMessageListBloc, String, void>(
      (chatId, _) => ChatMessageListBloc(
        chatId: chatId,
        getChatMessageListSlice: serviceLocator(),
        subscribeToChatMessageList: serviceLocator(),
        createChatMessage: serviceLocator(),
      ),
    );
}

void _initProfile() {
  serviceLocator
    ..registerLazySingleton<ProfileLocalDataSource>(
      () => DriftProfileLocalDataSource(serviceLocator()),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: serviceLocator(instanceName: 'authedDio'),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        logger: serviceLocator(),
        profileLocalDataSource: serviceLocator(),
        profileRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ResolveCurrentProfileUseCase(
        profileRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => ClearCachedCurrentProfileUseCase(
        profileRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => CreateProfileNameUseCase(
        profileRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ProfileNameOnboardingBloc(
        createProfileNameUseCase: serviceLocator(),
      ),
    );
}
