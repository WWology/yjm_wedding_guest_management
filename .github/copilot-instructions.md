# Copilot Instructions - Flutter Wedding Guest Management App

## Project Overview

This is a **Flutter web-only application** for managing wedding guests and RSVPs. The app has two user types:
- **Admins**: Manage guests, seating arrangements, and view all RSVP data
- **Guests**: Access via shared link to RSVP to the wedding

## Core Technology Stack

- **Framework**: Flutter (web-only target)
- **State Management**: flutter_bloc (BLoC pattern)
- **Code Generation**: Freezed (models, events, states), json_serializable, go_router_builder
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Routing**: go_router with type-safe navigation
- **UI Framework**: Material Design 3
- **Responsive Design**: responsive_framework with mobile/tablet/desktop breakpoints

## Architecture Principles

### 1. BLoC Pattern (State Management)

**ALWAYS use BLoC for state management.** Follow these patterns:

#### Event Structure
```dart
part of '[feature]_bloc.dart';

@freezed
sealed class [Feature]Event with _$[Feature]Event {
  const factory [Feature]Event.eventName({required Type param}) = EventName;
  const factory [Feature]Event.anotherEvent() = AnotherEvent;
}
```

**Naming conventions:**
- File: `[feature]_event.dart`
- Class: `[Feature]Event` (sealed, Freezed)
- Factory names: `.descriptiveActionName()` (camelCase)
- Implementation classes: `EventName` (PascalCase)
- Use `part of` to include in main bloc file

#### State Structure
```dart
part of '[feature]_bloc.dart';

@freezed
sealed class [Feature]State with _$[Feature]State {
  const factory [Feature]State.initial() = Initial;
  const factory [Feature]State.loading() = Loading;
  const factory [Feature]State.loaded({required List<Data> items}) = Loaded;
  const factory [Feature]State.error({required String message}) = Error;
}
```

**Naming conventions:**
- File: `[feature]_state.dart`
- Class: `[Feature]State` (sealed, Freezed)
- Common states: `.initial()`, `.loading()`, `.loaded()`, `.error()`, `.failure()`
- States can carry data using named parameters
- Use `part of` to include in main bloc file

#### BLoC Implementation
```dart
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../service/[feature]_service.dart';
import '../model/[model].dart';

part '[feature]_bloc.freezed.dart';
part '[feature]_event.dart';
part '[feature]_state.dart';

class [Feature]Bloc extends Bloc<[Feature]Event, [Feature]State> {
  [Feature]Bloc({required [Feature]Service service})
      : _service = service,
        super(const [Feature]State.initial()) {
    on<EventName>(_onEventName);
    on<AnotherEvent>(_onAnotherEvent);
  }

  final [Feature]Service _service;
  StreamSubscription? _subscription;

  Future<void> _onEventName(
    EventName event,
    Emitter<[Feature]State> emit,
  ) async {
    emit(const [Feature]State.loading());
    try {
      final result = await _service.someMethod(event.param);
      emit([Feature]State.loaded(items: result));
    } catch (error, stackTrace) {
      emit([Feature]State.error(message: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

**BLoC Guidelines:**
- Service dependency injection via constructor
- Store services as private fields with `_` prefix
- Register event handlers using `on<EventType>(_onHandlerMethod)`
- Private handler methods: `Future<void> _onEventName(Event event, Emitter<State> emit)`
- Cancel subscriptions in `close()` override when managing streams
- Use try-catch for error handling and emit error states

### 2. Freezed Models (Immutability)

**ALWAYS use Freezed for all data models.** Follow these patterns:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[model].freezed.dart';
part '[model].g.dart';

@freezed
class [Model] with _$[Model] {
  const factory [Model]({
    required String id,
    required String name,
    String? optionalField,
    @Default(false) bool boolField,
    @Default([]) List<String> listField,
  }) = _[Model];

  factory [Model].fromJson(Map<String, dynamic> json) => _$[Model]FromJson(json);
}
```

**Freezed Guidelines:**
- Always add both `part '[model].freezed.dart'` and `part '[model].g.dart'`
- Use `@freezed` decorator for immutable models
- Single factory constructor with named parameters
- Mark required fields with `required`
- Use `@Default(value)` for default values
- Include `fromJson` factory for JSON deserialization (automatic `toJson()`)
- Define enums in the same file when model-specific

### 3. Module Structure (3-Folder Approach)

**ALWAYS organize features using this exact structure:**

```
lib/modules/[feature]/
  ├── [feature].dart              # Barrel file - export public API
  ├── bloc/
  │   ├── [feature]_bloc.dart     # Main bloc file
  │   ├── [feature]_event.dart    # Events (part of bloc)
  │   ├── [feature]_state.dart    # States (part of bloc)
  │   └── [feature]_bloc.freezed.dart  # Generated
  ├── model/
  │   ├── [model].dart            # Data model
  │   ├── [model].freezed.dart    # Generated
  │   └── [model].g.dart          # Generated
  └── service/
      └── [feature]_service.dart  # Firebase/backend integration
```

**Barrel File Pattern** (`[feature].dart`):
```dart
export 'bloc/[feature]_bloc.dart';
export 'model/[model].dart';
// Do NOT export service unless needed publicly
```

**Module Guidelines:**
- Each feature MUST have `/bloc`, `/model`, `/service` folders
- Barrel file exports only public-facing APIs (bloc, models)
- Services are typically not exported (used internally by bloc)
- Pages/widgets go in `lib/pages/[page_name]/` directory

### 4. Service Layer (Firebase Integration)

**Service Pattern:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import '../model/[model].dart';

class [Feature]Service {
  [Feature]Service({
    FirebaseFirestore? firestore,
    fba.FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? fba.FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final fba.FirebaseAuth _firebaseAuth;

  CollectionReference<[Model]> get _collection =>
      _firestore.collection('[collection_name]').withConverter<[Model]>(
        fromFirestore: (snapshot, _) => [Model].fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  Stream<List<[Model]>> get items {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<void> addItem([Model] item) async {
    await _collection.doc(item.id).set(item);
  }

  Future<void> updateItem([Model] item) async {
    await _collection.doc(item.id).update(item.toJson());
  }

  Future<void> deleteItem(String id) async {
    await _collection.doc(id).delete();
  }
}
```

**Service Guidelines:**
- Accept optional Firebase instances for testability
- Use null-aware operators with defaults: `firestore ?? FirebaseFirestore.instance`
- Alias Firebase Auth: `import 'package:firebase_auth/firebase_auth.dart' as fba;`
- Use typed converters with `.withConverter<T>()` for type safety
- Expose streams for real-time data (BLoCs subscribe to streams)
- **Implement offline support**: Enable Firestore persistence for offline caching
- Handle pagination with cursor tracking for large datasets

### 5. Error Handling Pattern

**Custom Exception Classes:**

```dart
class [Operation]Failure implements Exception {
  const [Operation]Failure([
    this.message = 'An unknown error occurred.',
    this.stackTrace,
  ]);

  final String message;
  final StackTrace? stackTrace;

  factory [Operation]Failure.fromCode(String code) {
    switch (code) {
      case 'firebase-error-code':
        return const [Operation]Failure('User-friendly message');
      case 'another-error-code':
        return const [Operation]Failure('Another message');
      default:
        return const [Operation]Failure();
    }
  }
}
```

**Error Handling in Services:**
```dart
try {
  await _firestore.collection('items').doc(id).set(data);
} on FirebaseException catch (e) {
  throw [Operation]Failure.fromCode(e.code);
} catch (e, stackTrace) {
  throw [Operation]Failure(e.toString(), stackTrace);
}
```

### 6. Routing with go_router

**Router Setup** (`lib/routes.dart`):

```dart
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

final router = GoRouter(
  routes: $appRoutes,
  redirect: (context, state) {
    // Auth redirect logic
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is Authenticated;
    final isLoggingIn = state.matchedLocation == LoginRoute().location;

    if (!isAuthenticated && !isLoggingIn) return LoginRoute().location;
    if (isAuthenticated && isLoggingIn) return GuestsRoute().location;
    return null;
  },
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
);
```

**AppShell Pattern (Admin-Only Routes):**

```dart
@TypedShellRoute<AppShellRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<GuestsRoute>(path: '/guests'),
    TypedGoRoute<SeatingRoute>(path: '/seating'),
    // All admin routes go here
  ],
)
class AppShellRoute extends ShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppShell(child: navigator);
  }
}
```

**Public Routes (Outside AppShell):**

```dart
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

@TypedGoRoute<RsvpRoute>(path: '/rsvp/:guestId')
class RsvpRoute extends GoRouteData {
  const RsvpRoute({required this.guestId});
  final String guestId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RsvpPage(guestId: guestId);
  }
}
```

**Routing Guidelines:**
- **Everything inside `AppShellRoute` is admin-only** (requires authentication)
- **Public routes (login, RSVP) are outside `AppShellRoute`** (no authentication required)
- Use type-safe navigation: `GuestsRoute().go(context)`, `RsvpRoute(guestId: id).push(context)`
- Available methods: `.go()`, `.push()`, `.pushReplacement()`, `.replace()`
- Use global redirect function for authentication flow
- Run `dart run build_runner build --delete-conflicting-outputs` after route changes

### 7. Guest Management Features

**Guest Model Requirements:**

```dart
@freezed
class Guest with _$Guest {
  const factory Guest({
    required String id,
    required String name,
    String? email,
    String? phone,
    @Default(AttendanceStatus.pending) AttendanceStatus rsvpStatus,
    @Default([]) List<String> plusOnes,  // List of guest IDs
    String? groupId,  // For group invitations
    String? assignedTable,  // For seating arrangements
    int? seatNumber,
    DateTime? rsvpDate,
    String? notes,
  }) = _Guest;

  factory Guest.fromJson(Map<String, dynamic> json) => _$GuestFromJson(json);
}

enum AttendanceStatus {
  pending,
  attending,
  notAttending,
}
```

**Key Features to Implement:**
- **RSVP Status Tracking**: pending, attending, not attending
- **Plus-Ones**: Guest can have multiple plus-ones (linked by ID)
- **Group Invitations**: Multiple guests can share a `groupId`
- **Seating Arrangements**: Assign table and seat numbers
- **Admin Management**: Full CRUD operations for admins
- **Guest RSVP Flow**: Public link access for guests to submit RSVP

**Service Considerations:**
- Implement real-time listeners for guest list updates
- Support filtering by RSVP status, table assignment, etc.
- Implement search functionality across guest names/emails
- Handle plus-one cascading operations (e.g., deleting guest removes plus-ones)

### 8. UI/UX Guidelines

**Material Design 3:**
- Use Material 3 components and theming
- Theme defined in `lib/theme.dart` with light/dark modes
- Follow existing `MaterialTheme` class pattern
- Use Google Fonts (via `createTextTheme()` helper)

**Responsive Design Breakpoints** (responsive_framework):
```dart
MOBILE:  0-599px    // Single column, compact UI
TABLET:  600-839px  // Two columns, medium spacing
DESKTOP: 840-1199px // Multi-column, spacious layout
LARGE:   1200-1599px
XL:      1600px+
```

**Responsive Patterns:**
```dart
// Conditional layout based on breakpoint
if (ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
  // Desktop/tablet layout
} else {
  // Mobile layout
}

// Responsive values
ResponsiveValue<double>(
  context,
  defaultValue: 16.0,
  conditionalValues: [
    Condition.smallerThan(name: TABLET, value: 8.0),
    Condition.largerThan(name: DESKTOP, value: 24.0),
  ],
).value
```

**UI Guidelines:**
- App must work well on both mobile browsers and desktop browsers
- Use responsive layouts for all pages
- Implement touch-friendly tap targets for mobile
- Use adaptive navigation (drawer for mobile, rail/tab for desktop)
- Forms should be optimized for mobile keyboard input

### 9. Import/Export Organization

**Import Order:**
1. Flutter/Dart SDK imports
2. Package imports (alphabetically)
3. Relative imports (alphabetically)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/guest.dart';
import '../service/guest_service.dart';
```

**Barrel File Exports:**
- Every module and page directory has a barrel file named `[directory_name].dart`
- Barrel files export the public API: `export 'bloc/[feature]_bloc.dart';`
- Import from barrel files: `import 'modules/auth/auth.dart';` (gets all exports)

### 10. Code Generation Commands

**After modifying Freezed models, BLoC events/states, or routes:**

```bash
# Full rebuild (recommended)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (during active development)
dart run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**When to run:**
- After creating/modifying any `@freezed` class
- After adding/modifying routes with `go_router_builder`
- After changing JSON serialization annotations
- When you see "missing part" or "undefined" errors for generated code

### 11. Firebase Configuration

**Firestore Structure:**
```
/guests (collection)
  /{guestId} (document)
    - id, name, email, rsvpStatus, plusOnes[], groupId, assignedTable, etc.

/tables (collection)
  /{tableId} (document)
    - id, tableNumber, capacity, assignedGuests[]

/invitations (collection)
  /{invitationId} (document)
    - id, guestIds[], linkToken, expiresAt
```

**Security Considerations:**
- Admins: Full read/write access to all collections (requires authentication)
- Guests: Read/write only their own guest document via invitation token
- Public RSVP routes should validate invitation tokens before allowing updates
- Implement Firestore security rules to enforce access control

**Offline Support:**
- Enable Firestore persistence: `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);`
- Handle offline state in UI (show indicators when offline)
- Implement optimistic updates where appropriate
- Test offline → online sync behavior

### 12. Code Style Best Practices

- **Use `const` constructors** wherever possible for performance
- **Named parameters** preferred over positional (especially in events, models, widgets)
- **Trailing commas** on all parameter lists for better formatting
- **Private fields** use leading underscore: `_service`, `_firestore`
- **Type safety**: Use generics and avoid `dynamic` where possible
- **Null safety**: Leverage sound null safety, use `?` and `required` appropriately
- **BLoC Provider lazy loading**: Set `lazy: false` only when immediate initialization needed
- **Event dispatching**: Can use cascade notation: `bloc..add(event1)..add(event2)`
- **Exhaustive pattern matching**: Use `.when()`, `.map()`, or `.maybeWhen()` on Freezed unions

### 13. Testing Considerations

**When implementing new features:**
- Services should accept Firebase instances for testability
- BLoCs should accept service instances for dependency injection
- Use mock services in widget tests
- Test all BLoC state transitions
- Test error handling paths

### 14. Common Patterns Reference

**BLoC Provider Setup** (in main.dart or page):
```dart
BlocProvider(
  create: (context) => [Feature]Bloc(
    service: context.read<[Feature]Service>(),
  )..add(const [Feature]Event.subscriptionRequested()),
  child: ChildWidget(),
)
```

**BLoC Consumer Pattern:**
```dart
BlocBuilder<[Feature]Bloc, [Feature]State>(
  builder: (context, state) {
    return state.when(
      initial: () => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
      loaded: (items) => ListView(children: items.map(...).toList()),
      error: (message) => Text('Error: $message'),
    );
  },
)
```

**Stream Subscription in BLoC:**
```dart
Future<void> _onSubscriptionRequested(
  SubscriptionRequested event,
  Emitter<State> emit,
) async {
  await emit.forEach<List<Guest>>(
    _service.guests,
    onData: (guests) => State.loaded(guests: guests),
    onError: (error, stackTrace) => State.error(message: error.toString()),
  );
}
```

---

## Quick Reference Checklist

When implementing a new feature, ensure:

- [ ] Create module folder with `/bloc`, `/model`, `/service` structure
- [ ] Use `@freezed` for all models, events, and states
- [ ] Implement BLoC pattern with proper event handlers
- [ ] Add Firebase service with typed converters
- [ ] Create barrel file exporting public API
- [ ] Add routes using `go_router_builder` (inside/outside AppShell as needed)
- [ ] Implement responsive layouts for mobile/tablet/desktop
- [ ] Add proper error handling with custom exception classes
- [ ] Run `dart run build_runner build` to generate code
- [ ] Test on both mobile and desktop browser viewports
- [ ] Consider offline support and loading states
- [ ] Follow Material Design 3 guidelines

---

**This is a living document.** Update these instructions as the project evolves and new patterns emerge.
