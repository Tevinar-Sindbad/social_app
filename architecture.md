# Architecture

This document defines the project structure, the responsibilities of each
module, and the practical rules used to keep the codebase maintainable as it
grows.

## 1. Goals

The architecture is designed to provide:

- clear ownership of code
- explicit boundaries between business logic, app orchestration, and shared
  technical code
- low coupling between features
- predictable data flow
- scalability without widespread rewrites

### Layer Consistency Rule

The layers of this architecture are mandatory because they provide consistency
across features.

Even when one layer is only a thin pass-through for a specific feature today,
it should still exist if it belongs to the reference architecture.

That consistency gives three benefits:

- it keeps the same mental model from one feature to another
- it makes it obvious which layer should call which other layer
- it leaves room for future logic to be added in the correct place without
  reshuffling the whole structure later

---

## 2. Responsibilities by Module

### `core/`

Purpose:

- passive, feature-agnostic technical building blocks

Typical contents:

- generic shared errors, generic fallback failure mapping, and low-level
  abstractions
- configuration access
- shared constants
- local database and local file storage infrastructure
- generic media helpers
- generic networking and SSE primitives
- serialization helpers
- shared theme and UI primitives
- shared use case interfaces
- reusable utilities
- technical service abstractions

Must not contain:

- business concepts such as `User`, `Post`, or `Chat`
- feature-specific failure messages or feature-specific failure mappers
- feature use cases
- app flows, navigation, or orchestration logic
- BLoCs or Cubits

Rule:

- code in `core/` should still make sense if all features were removed

### `app/`

Purpose:

- application-wide orchestration

Typical contents:

- bootstrap and startup coordination
- app-level state and truly global coordination
- dependency injection wiring
- shared runtime networking owned by the app layer
- routing and route guards
- app-scoped use cases
- app shell
- app-wide logging integration
- concrete shared service implementations when they are truly global

Must not contain:

- feature-specific business logic
- feature persistence details
- domain rules owned by a single feature

Rule:

- `app/` coordinates features, but is not a business layer
- app-level state should exist only when the concern is truly global

In this project, app-wide coordination is centered on:

- `app/bootstrap` for startup
- `app/session` for global signed-in app user coordination
- `app/network` for shared runtime networking such as SSE clients
- `app/router` for navigation
- `app/use_cases` for app-scoped actions such as clearing session data
- `GetIt` for dependency composition
- `GoRouter` for navigation
- BLoC/Cubit for state management
- `StreamUseCase` for cache-first and other reactive feature reads

When a feature read is cache-first and reactive, prefer `StreamUseCase` plus a
domain snapshot/result type instead of duplicating cache and remote handling in
the UI.

### `features/*/domain/`

Purpose:

- business-facing logic and contracts for a feature

Typical contents:

- entities
- value objects and other domain-owned subfolders such as `events`,
  `results`, `read_models`, and `pagination` when they clarify intent
- feature-owned failures, failure messages, and failure mappers in
  `domain/failures`
- use cases in the feature domain use-case folder (`domain/usecases` or
  `domain/use_cases`, depending on the feature's established naming)
- repository interfaces

Must not contain:

- transport models
- UI logic
- external system implementations

### `features/*/data/`

Purpose:

- infrastructure details and external integration for a feature

Typical contents:

- transport and persistence models in `data/models`
- repository implementations in `data/repositories`
- data sources in `data/sources` when they add real clarity
- external persistence and API integration

Must not contain:

- UI logic
- navigation behavior
- feature presentation state

Rule:

- `data/` may talk to SDKs, APIs, databases, or local storage directly
- an extra data-source layer is optional, not mandatory
- new abstractions should be introduced only when they add real clarity
- when an SDK already acts as the external boundary, repository code may call
  it directly instead of wrapping it in a redundant `data/sources` adapter
  layer. That's the case for Supabase auth.

### `features/*/presentation/`

Purpose:

- UI rendering and feature-scoped state coordination

Typical contents:

- pages
- widgets
- BLoCs and Cubits
- events and states
- feature UI state

Must not contain:

- direct persistence logic
- low-level infrastructure details
- external API handling

Rules:

- feature BLoCs coordinate behavior, not low-level technical details
- mapping logic belongs in models, repositories, or dedicated mappers, not in
  the UI
- widget-bound UI state such as `ScrollController`, focus nodes, text
  controllers, measured layout, and other node-bound interaction state should
  stay in pages or widgets, not in BLoCs

---

## 3. Dependency Rules

The default dependency direction is:

```text
app/** bootstrap|router|session entrypoint
↓
features/*/presentation/pages|widgets
↓
features/*/presentation/blocs/**
↓
features/*/domain/use_cases/**
↓
features/*/domain/repositories/**
↓
features/*/data/repositories/**
↓
may use:
features/*/data/sources/** (not used for communicating with the auth provider, which is currently supabase)
features/*/data/models/**
features/*/data/network/**
```

### Global rule

- `core/**` is a support layer, not a primary orchestration step
- `app/**` appears only when coordination is truly app-wide or cross-feature
- sharing across features is exceptional. When it happens, only use-cases are allowed
  to be shared and it has to go through an `app/` helper.

---

## 4. Runtime and Data Flow

### Command flow

1. a user interacts with a page or widget
2. a BLoC or Cubit in `presentation/` receives the intent
3. it invokes a use case from `domain/`
4. the use case delegates to a repository contract
5. the repository implementation in `data/` performs the technical work
6. results are mapped back to domain entities or failures
7. the BLoC emits a new UI state

### Naming convention

Use read names to signal where updates come from:

- `subscribe` = server-pushed events
- `observe` = local/cache/reactive streams
- `get` = one-shot reads

### Auth and app-session ownership

Auth and app session are intentionally split across systems:

- Supabase Auth owns credentials, email confirmation, deep-link callback
  processing, and raw auth session persistence
- the Nest backend owns the internal application user, profile onboarding, and
  business authorization
- `app/session/AppUserCubit` combines those two sides into global app states
  such as signed out, needs onboarding, signed in, or failure

That separation is why the app keeps a backend-owned app user in addition to
the Supabase auth identity. The backend user is the stable application
identity, while external auth identities may evolve over time and may later be
linked from multiple sign-in providers.

### Auth session flow

The auth feature exposes a small session event model to the app layer:

- `InitialSession`
- `SignedIn`
- `SignedOut`

`AppUserCubit` consumes those events, then resolves the backend profile before
emitting app-global user state. Because profile resolution is asynchronous,
`AppUserCubit` also guards against stale async completions so that an older
request cannot overwrite a newer signed-in or signed-out state.

### Server-pushed flow

1. a remote data source or repository exposes a backend-driven stream
2. a use case exposes that stream to presentation
3. a BLoC subscribes to the stream
4. stream emissions are converted into BLoC events
5. state changes still go through the BLoC event pipeline

### Local/cache-reactive flow

When stale local data is still useful, the reactive flow becomes local-first:

1. a repository reads local cache first
2. the repository emits a domain snapshot from cache
3. the repository refreshes from the backend
4. the repository emits fresh remote data or a refresh failure attached to the
   stale cached snapshot
5. the BLoC updates UI state without duplicating cache and remote emissions

### Deep-linkable page rule

Pages that should support deep links, push notifications, or state restoration
must receive primitive route parameters (string, integer, boolean...), rather
than rich domain objects. That rule keeps route contracts serializable.

This keeps entry points consistent whether the user opens a page from in-app
navigation, a deep link, a push notification, or a restored app session.

## 5. Error Handling

Errors are handled according to their level:

- infrastructure code may throw technical exceptions
- repositories map those exceptions into safe `Failure` objects. Feature-owned
  mappers handle feature-specific backend codes first, then delegate unknown
  cases to the generic core mapper. Only unexpected failures are logged in
  production code.
- currently, local data source exceptions are bubled up to reposiry layer without
  filtering and are collapsed into `UnexpectedFailure`. The reasons:
  - users do not need to have dedicated messages for these exceptions
  - repositories do not change their behavior depending on local data exception types
    If one day, one of these two reasons become false, then adding a filtering will
    be necessary.
- use cases and presentation consume `Either<Failure, T>`
- UI receives intentional, user-safe messages
- logs may keep richer technical details than UI state

Failure ownership rules:

- `core/errors` owns generic failure types, generic shared failure messages,
  and the generic fallback mapper
- `features/*/domain/failures/` owns feature-specific failure messages and
  feature-specific exception-to-failure mappers
- repositories use the mapper owned by their feature, not the generic core
  mapper directly when feature-specific backend codes exist

Logging rules:

- repositories log unexpected failures with Talker and send them to Sentry
  because they convert thrown exceptions into `Failure` objects that would
  otherwise stop bubbling
- `FlutterError.onError` in
  `lib/app/bootstrap/configure_global_error_handling.dart` sends Flutter
  framework exceptions to Sentry (for example build, layout, paint, BLoC, and
  uncaught domain/runtime errors inside framework callbacks)
- `PlatformDispatcher.instance.onError` in
  `lib/app/bootstrap/configure_global_error_handling.dart` sends top-level
  async/runtime errors outside Flutter framework callbacks to Sentry
- local debugging does not need duplicate Talker logs for those uncaught
  exceptions because Flutter already surfaces their stack traces

---

## 6. Testing Strategy

Testing should prioritize behavior over surface area.

Recommended focus:

- unit tests for use cases, repositories, mappers, and BLoCs/Cubits
- focused widget tests for critical screens and interactions
- integration tests where external boundaries matter

Practical rules:

- test business behavior inside features first
- mock data sources when testing repositories
- mock repositories or use cases when testing BLoCs/Cubits
- keep helpers and mappers easy to test in isolation
- low-signal bootstrap or declarative wiring does not need the same testing
  priority as behavior-owning code

The goal is not mechanical coverage. The goal is to test code that owns
decisions and behavior.

## 7. Adding or Evolving a Feature

Recommended sequence:

1. Feature domain:
   - define the use cases and repository contracts the feature needs
   - create entities, value objects, and failures for business invariants
2. Feature data:
   - implement repository adapters
   - local / remote integrations
3. Feature presentation: expose the feature through pages, widgets, and BLoC / Cubit state
4. wire dependencies in `app/bootstrap` and add routes if needed
5. update local persistence or cache schema if storage changes
6. update app-level coordinators only if new global state must surface
