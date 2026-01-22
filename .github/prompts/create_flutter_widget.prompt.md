---
agent: agent
tools: ['dart-sdk-mcp-server/*', 'edit', 'read', 'search', 'web']
description: Create a Flutter widget for the wedding guest management app following project conventions and best practices.

---

# Create Flutter Widget Prompt

You are helping to create a new Flutter widget for the wedding guest management app. Follow these step-by-step instructions to ensure the widget follows project conventions and best practices.

## Context & Requirements

**Project Overview:**
- Flutter web-only application for wedding guest and RSVP management
- Two user types: Admins (authenticated) and Guests (public RSVP via link)
- BLoC state management with Freezed models
- Material Design 3 with responsive layouts (mobile/tablet/desktop)
- Firebase backend (Firestore, Authentication)

**Reference Project Instructions:** @.github/copilot-instructions.md for complete architectural patterns and conventions.

---

## Step 1: Determine Widget Type

Ask the user which type of widget to create:

### A. Page Widget (Routable Screen)
- Full-screen view with its own route
- Examples: @lib/pages/login/login_page.dart, @lib/pages/guest_list/guest_list_page.dart
- Location: `lib/pages/[page_name]/[page_name]_page.dart`
- Includes: Scaffold, AppBar (for mobile), responsive layout

### B. Form Widget
- User input with validation
- Example: @lib/pages/login/login_form.dart
- Uses: ValueNotifier for error states, Form with validation
- Location: `lib/pages/[feature]/[form_name]_form.dart` or `widgets/`

### C. Reusable Component (Card, List Item, etc.)
- Presentational widget used in multiple places
- Examples: Cards, list tiles, buttons, dialogs
- Location: `lib/common/[component_name].dart` or `lib/pages/[feature]/widgets/`

### D. Layout/Shell Widget
- Structural widget providing navigation/layout
- Example: @lib/common/app_shell.dart
- Location: `lib/common/[widget_name].dart`

---

## Step 2: Gather Requirements

Ask the user to clarify:

1. **Widget Name:** What should the widget be called?
2. **Purpose:** What does this widget do?
3. **Data:** What data does it receive or display?
4. **State Management:** Does it need BLoC integration? Which BLoC?
5. **Responsive:** Does layout change between mobile/desktop?
6. **Access Control:** Is this admin-only or public-facing?
7. **Interactions:** What user actions are supported (tap, edit, delete, etc.)?

---

## Step 3: Choose StatelessWidget or StatefulWidget

**Default to StatelessWidget** unless the widget needs:
- Internal navigation state (selected index, page controller)
- Animation controllers
- Form controllers that can't use ValueNotifier

**Use StatelessWidget with:**
- BLoC for business logic (recommended pattern)
- ValueNotifier for local reactive state (form errors, toggles)
- Constructor parameters for data

**Examples:**
- StatelessWidget: @lib/pages/login/login_page.dart, @lib/pages/login/login_form.dart
- StatefulWidget: @lib/common/app_shell.dart (manages navigation index)

---

## Step 4: Implement Responsive Design

**ALWAYS use single breakpoint check:**

```dart
final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
```

**Breakpoints:**
- MOBILE: 0-599px
- TABLET: 600-839px
- DESKTOP: 840-1199px+

**Choose responsive strategy:**

### Strategy A: Separate Widget Classes (for significant layout differences)
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return isLargeScreen ? const LargeScreenMyPage() : const SmallScreenMyPage();
  }
}
```
**See:** @lib/pages/login/login_page.dart

### Strategy B: Inline Conditionals (for minor differences)
```dart
Scaffold(
  appBar: !isLargeScreen ? AppBar(...) : null,
  bottomNavigationBar: isLargeScreen ? null : NavigationBar(...),
)
```
**See:** @lib/common/app_shell.dart

### Strategy C: LayoutBuilder (for dynamic sizing)
```dart
LayoutBuilder(
  builder: (context, constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth < 624 ? 312 : constraints.maxWidth / 2,
      ),
      child: content,
    );
  },
)
```
**See:** @lib/common/search_app_bar.dart

---

## Step 5: Apply Material Design 3 Theming

**ALWAYS use ColorScheme for colors (Material 3):**

```dart
final colorScheme = ColorScheme.of(context);
final textTheme = Theme.of(context).textTheme;

// Background colors
colorScheme.surface
colorScheme.surfaceContainer
colorScheme.surfaceContainerHigh

// Primary colors
colorScheme.primary
colorScheme.onPrimary
colorScheme.primaryContainer

// Text styles
textTheme.headlineLarge
textTheme.bodyMedium
textTheme.labelSmall
```

**See theming examples:** @lib/common/search_app_bar.dart, @lib/pages/guest_list/guest_list_page.dart

**For brightness-aware assets:**
```dart
Theme.brightnessOf(context) == Brightness.light
  ? const Image(image: AssetImage('assets/images/logo_black.png'))
  : const Image(image: AssetImage('assets/images/logo_white.png'))
```
**See:** @lib/common/app_shell.dart

---

## Step 6: Integrate BLoC (if needed)

### For App-Level State
Provide BLoC at app level in @lib/main.dart:
```dart
BlocProvider(
  lazy: false,
  create: (_) => MyBloc(service: myService)
    ..add(const MyEvent.subscriptionRequested()),
  child: MyApp(),
)
```

### For Page-Level State
Provide BLoC at page level:
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc(service: context.read<MyService>()),
      child: MyPageContent(),
    );
  }
}
```

### BlocConsumer (Side Effects + UI)
Use when you need navigation, snackbars, or dialogs:
```dart
BlocConsumer<AuthBloc, AuthState>(
  listenWhen: (previous, current) => previous is Loading,
  listener: (context, state) {
    // Side effects: navigation, snackbars
    if (state case Unauthenticated(:final message)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } else if (state is Authenticated) {
      GuestsRoute().go(context);
    }
  },
  builder: (context, state) {
    // UI rendering
    return state.when(
      loading: () => const CircularProgressIndicator(),
      loaded: (data) => MyContent(data: data),
      error: (message) => Text('Error: $message'),
    );
  },
)
```
**See:** @lib/pages/login/login_form.dart

### BlocBuilder (UI Only)
Use when only UI needs to update:
```dart
BlocBuilder<GuestsBloc, GuestsState>(
  builder: (context, state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (guests) => GuestList(guests: guests),
      error: (message) => Text('Error: $message'),
    );
  },
)
```

### Event Dispatching
```dart
context.read<AuthBloc>().add(
  AuthEvent.loginRequested(email: email, password: password),
);
```

---

## Step 7: Forms & Validation (if applicable)

**Use ValueNotifier for reactive error indicators:**

```dart
class MyForm extends StatelessWidget {
  MyForm({super.key});

  final emailHasError = ValueNotifier(false);
  String? email;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ValueListenableBuilder(
        valueListenable: emailHasError,
        builder: (context, hasError, _) {
          return TextFormField(
            decoration: InputDecoration(
              labelText: 'Email*',
              helperText: 'required*',
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
              suffixIcon: hasError
                ? Icon(Icons.error_outline_rounded, color: ColorScheme.of(context).error)
                : null,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter email';
              return null;
            },
            onChanged: (value) => emailHasError.value = value.isEmpty,
            onSaved: (value) => email = value,
          );
        },
      ),
    );
  }
}
```

**Form submission:**
```dart
FilledButton(
  onPressed: () {
    final formState = Form.of(context);
    if (formState.validate()) {
      formState.save();
      context.read<MyBloc>().add(MyEvent.submitted(email: email!));
    }
  },
  child: const Text('Submit'),
)
```

**See complete example:** @lib/pages/login/login_form.dart

---

## Step 8: Add Accessibility (STRONGLY RECOMMENDED)

**Wrap interactive elements in Semantics:**

```dart
// For buttons
Semantics(
  label: 'Add new guest',
  button: true,
  child: FloatingActionButton(
    onPressed: _handleAdd,
    child: const Icon(Icons.add),
  ),
)

// For images
Semantics(
  label: 'Company logo',
  image: true,
  child: Image.asset('assets/images/logo.png'),
)

// For custom gestures
Semantics(
  label: 'Delete guest',
  button: true,
  onTap: _handleDelete,
  child: GestureDetector(
    onTap: _handleDelete,
    child: const Icon(Icons.delete),
  ),
)
```

**Accessibility requirements:**
- Interactive elements: At least 48x48 logical pixels
- Text contrast: 4.5:1 ratio (3:1 for large text 18pt+)
- Form fields: Use `labelText` and `helperText` for screen readers
- Decorative elements: Wrap in `ExcludeSemantics`

---

## Step 9: Organize Imports

**Follow this order:**
1. Flutter/Dart SDK imports
2. Package imports (alphabetically)
3. Relative imports (alphabetically)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../modules/guests/guests.dart';
import '../common/common.dart';
```

---

## Step 10: Pre-Submission Checklist

**STRONGLY RECOMMENDED to verify before completing:**

### Structure
- [ ] Used StatelessWidget unless StatefulWidget is necessary
- [ ] File placed in correct directory (`lib/pages/` or `lib/common/`)
- [ ] Constructor uses `super.key` and named parameters
- [ ] Uses `const` constructors where possible

### Responsive Design
- [ ] Uses `ResponsiveBreakpoints.of(context).largerThan(TABLET)` pattern
- [ ] Appropriate responsive strategy chosen
- [ ] Tested mentally for mobile (< 600px) and desktop (> 840px)

### Theming
- [ ] Uses `ColorScheme.of(context)` for all colors
- [ ] Uses `Theme.of(context).textTheme` for text styles
- [ ] No hardcoded colors (unless semantically meaningful)
- [ ] Works in both light and dark themes

### BLoC Integration (if applicable)
- [ ] BLoC provided at appropriate level
- [ ] Uses `BlocConsumer` for side effects + UI or `BlocBuilder` for UI-only
- [ ] Events dispatched with `context.read<Bloc>()`
- [ ] State handled exhaustively with `.when()` or pattern matching

### Forms (if applicable)
- [ ] Uses `ValueNotifier` for error indicators
- [ ] Validation with `autovalidateMode: AutovalidateMode.onUserInteraction`
- [ ] Proper `keyboardType` and `textInputAction`
- [ ] Form validates and saves before dispatching event

### Accessibility
- [ ] Interactive elements wrapped in `Semantics` with labels
- [ ] Images have semantic labels
- [ ] Tap targets are 48x48 pixels minimum
- [ ] Text has proper contrast ratio

### Code Quality
- [ ] Imports organized correctly
- [ ] No unused imports or variables
- [ ] Follows project naming conventions
- [ ] Ready for `dart format`

---

## Widget Type-Specific Guidance

### For Page Widgets (Admin-Only)
- Include in @lib/routes.dart inside `@TypedShellRoute<AppShellRoute>`
- Provide Scaffold with responsive AppBar
- Consider adding FAB for primary actions
- Use BLoC for data fetching

### For Page Widgets (Public-Facing)
- Define routes OUTSIDE `AppShellRoute` in @lib/routes.dart
- No authentication required
- Simpler navigation (no app shell)
- Example: RSVP page accessible via shared link

### For Form Widgets
- Always use `ValueNotifier` for error states
- Use `autovalidateMode: AutovalidateMode.onUserInteraction`
- Validate before dispatching BLoC events
- Consider loading state during submission

### For Reusable Components
- Accept all data via constructor
- No BLoC dependency (receive data from parent)
- Use callbacks for interactions: `final VoidCallback onTap;`
- Make maximally reusable and testable

---

## Examples from Codebase

**Reference these for patterns:**

- **Responsive Page:** @lib/pages/login/login_page.dart
- **Form with Validation:** @lib/pages/login/login_form.dart
- **BLoC Integration:** @lib/pages/guest_list/guest_list_page.dart
- **Navigation Shell:** @lib/common/app_shell.dart
- **Themed Component:** @lib/common/search_app_bar.dart
- **Routing:** @lib/routes.dart
- **Theme Configuration:** @lib/theme.dart
- **Main App Setup:** @lib/main.dart

---

## Final Notes

- **When in doubt, follow existing patterns** in the codebase
- **Consistency is more important than perfection**
- **Reference @.github/copilot-instructions.md** for complete architectural guidelines
- **Accessibility is not optional** - always include Semantics
- **Test responsive behavior** mentally or with browser dev tools

Now, let's create your Flutter widget! What type of widget would you like to create?

## Responsive Design

### Breakpoint System
The app uses `responsive_framework` with these breakpoints:

```dart
MOBILE:  0-599px    // Phone screens
TABLET:  600-839px  // Tablets
DESKTOP: 840-1199px // Desktop/laptop
LARGE:   1200-1599px
XL:      1600px+
```

### Single Breakpoint Check (Required Pattern)
**ALWAYS use this pattern** to differentiate between small and large layouts:

```dart
final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
```

### Responsive Layout Strategies

#### Strategy 1: Separate Widget Classes (Recommended for Pages)
**Use when:** Layout differences are significant

```dart
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return Scaffold(
      body: isLargeScreen
        ? const LargeScreenMyPage()
        : const SmallScreenMyPage(),
    );
  }
}

class LargeScreenMyPage extends StatelessWidget {
  const LargeScreenMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Desktop layout: multi-column, navigation rail
  }
}

class SmallScreenMyPage extends StatelessWidget {
  const SmallScreenMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mobile layout: single column, bottom navigation
  }
}
```

**Example:** [lib/pages/login/login_page.dart](../../lib/pages/login/login_page.dart)

#### Strategy 2: Inline Conditionals (For Smaller Changes)
**Use when:** Only a few properties differ

```dart
@override
Widget build(BuildContext context) {
  final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

  return Scaffold(
    appBar: !isLargeScreen ? AppBar(...) : null,
    body: Row(
      children: [
        if (isLargeScreen) NavigationRail(...),
        Expanded(child: content),
      ],
    ),
    bottomNavigationBar: isLargeScreen ? null : NavigationBar(...),
  );
}
```

**Example:** [lib/common/app_shell.dart](../../lib/common/app_shell.dart)

#### Strategy 3: LayoutBuilder (For Dynamic Sizing)
**Use when:** Widget size depends on available constraints

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth < 624
          ? 312
          : constraints.maxWidth / 2,
      ),
      child: MyContent(),
    );
  },
)
```

**Example:** [lib/common/search_app_bar.dart](../../lib/common/search_app_bar.dart)

---

## Material Design 3 & Theming

### Accessing Theme Colors

#### ColorScheme (Material 3) - Preferred
```dart
// Background colors
ColorScheme.of(context).surface
ColorScheme.of(context).surfaceContainerHigh
ColorScheme.of(context).surfaceContainer

// Primary colors
ColorScheme.of(context).primary
ColorScheme.of(context).onPrimary
ColorScheme.of(context).primaryContainer

// Other semantic colors
ColorScheme.of(context).error
ColorScheme.of(context).outline
ColorScheme.of(context).shadow
```

**Example:** [lib/common/search_app_bar.dart](../../lib/common/search_app_bar.dart)

#### Theme Properties
```dart
// Typography
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.bodyMedium
Theme.of(context).textTheme.labelSmall

// Component themes
Theme.of(context).cardTheme.color
Theme.of(context).appBarTheme.backgroundColor
Theme.of(context).iconTheme.color
```

**Example:** [lib/pages/guest_list/guest_list_page.dart](../../lib/pages/guest_list/guest_list_page.dart)

### Brightness-Aware Assets
```dart
// Load different assets based on light/dark theme
Theme.brightnessOf(context) == Brightness.light
  ? const Image(image: AssetImage(''assets/images/logo_black.png''))
  : const Image(image: AssetImage(''assets/images/logo_white.png''))
```

**Example:** [lib/common/app_shell.dart](../../lib/common/app_shell.dart) and [lib/pages/login/login_page.dart](../../lib/pages/login/login_page.dart)

### Material 3 Components
Use Material 3 components for consistency:
- `FilledButton` (primary actions)
- `OutlinedButton` (secondary actions)
- `TextButton` (tertiary actions)
- `Card` with `elevation` property
- `NavigationBar` (mobile bottom nav)
- `NavigationRail` (desktop side nav)

---

## BLoC Integration

### App-Level BLoC Provider
For feature-wide BLoCs, provide at app level in `main.dart`:

```dart
BlocProvider(
  lazy: false,  // Set false for immediate initialization
  create: (_) => FeatureBloc(service: featureService)
    ..add(const FeatureEvent.subscriptionRequested()),
  child: MyApp(),
)
```

**Example:** [lib/main.dart](../../lib/main.dart) - AuthBloc

### Page-Level BLoC Provider
For page-specific BLoCs:

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBloc(
        service: context.read<MyService>(),
      )..add(const MyEvent.started()),
      child: MyPageContent(),
    );
  }
}
```

### BlocConsumer Pattern (Side Effects + UI)
**Use when:** Need to handle both UI updates and side effects (navigation, snackbars)

```dart
BlocConsumer<AuthBloc, AuthState>(
  listenWhen: (previous, current) => previous is Loading,
  listener: (context, state) {
    // Side effects: navigation, snackbars, dialogs
    if (state case Unauthenticated(:final message) when message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else if (state is Authenticated) {
      GuestsRoute().go(context);
    }
  },
  builder: (context, state) {
    // UI rendering based on state
    return state.when(
      initial: () => const SizedBox(),
      loading: () => const CircularProgressIndicator(),
      authenticated: (user) => Text(''Welcome ${user.name}''),
      unauthenticated: (_) => const LoginForm(),
      error: (message) => Text(''Error: $message''),
    );
  },
)
```

**Example:** [lib/pages/login/login_form.dart](../../lib/pages/login/login_form.dart)

### BlocBuilder (UI Only)
**Use when:** Only need to update UI, no side effects

```dart
BlocBuilder<GuestsBloc, GuestsState>(
  builder: (context, state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (guests) => ListView.builder(
        itemCount: guests.length,
        itemBuilder: (context, index) => GuestTile(guest: guests[index]),
      ),
      error: (message) => Center(child: Text(''Error: $message'')),
    );
  },
)
```

### BlocListener (Side Effects Only)
**Use when:** Only need side effects, no UI changes

```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      router.refresh();
    }
  },
  child: MyWidget(),
)
```

**Example:** [lib/main.dart](../../lib/main.dart)

### Event Dispatching
```dart
// Using context.read
context.read<AuthBloc>().add(
  AuthEvent.loginRequested(
    email: email,
    password: password,
  ),
);

// Using BlocProvider.of (alternative)
BlocProvider.of<AuthBloc>(context).add(...);
```

---

## Forms & Validation

### ValueNotifier for Error States
**Use ValueNotifier** for reactive error indicators without StatefulWidget:

```dart
class MyForm extends StatelessWidget {
  MyForm({super.key});

  final emailHasError = ValueNotifier(false);
  final passwordHasError = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: emailHasError,
            builder: (context, hasError, child) {
              return TextFormField(
                decoration: InputDecoration(
                  suffixIcon: hasError
                    ? const Icon(Icons.error_outline_rounded, color: Colors.red)
                    : null,
                ),
                onChanged: (value) {
                  emailHasError.value = value.isEmpty;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
```

**Example:** [lib/pages/login/login_form.dart](../../lib/pages/login/login_form.dart)

### TextFormField Configuration
```dart
TextFormField(
  // Input type
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,

  // Security
  obscureText: true,
  enableSuggestions: false,
  autocorrect: false,

  // Decoration
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.email),
    labelText: ''Email*'',
    helperText: ''required*'',
    border: OutlineInputBorder(),
    suffixIcon: hasError
      ? Icon(Icons.error_outline_rounded, color: Colors.red)
      : null,
  ),

  // Validation
  validator: (value) {
    if (value == null || value.isEmpty) {
      return ''Please enter your email'';
    }
    return null;
  },
  autovalidateMode: AutovalidateMode.onUserInteraction,

  // State management
  onSaved: (newValue) => email = newValue,
  onChanged: (value) {
    emailHasError.value = value.isEmpty;
  },
)
```

**Example:** [lib/pages/login/login_form.dart](../../lib/pages/login/login_form.dart)

### Form Submission
```dart
FilledButton(
  onPressed: () {
    final formState = Form.of(context);
    if (formState.validate()) {
      formState.save();

      // Dispatch event to BLoC
      context.read<AuthBloc>().add(
        AuthEvent.loginRequested(
          email: email!,
          password: password!,
        ),
      );
    }
  },
  child: const Text(''Submit''),
)
```

---

## Accessibility

### Semantic Labels (ALWAYS Include)
```dart
// For interactive widgets
Semantics(
  label: ''Login button'',
  button: true,
  child: FilledButton(
    onPressed: _handleLogin,
    child: const Text(''Login''),
  ),
)

// For images
Semantics(
  label: ''Company logo'',
  image: true,
  child: Image.asset(''assets/images/logo.png''),
)

// For custom gestures
Semantics(
  label: ''Delete guest'',
  button: true,
  onTap: _handleDelete,
  child: GestureDetector(
    onTap: _handleDelete,
    child: Icon(Icons.delete),
  ),
)
```

### Excluding Decorative Elements
```dart
// For purely decorative elements
ExcludeSemantics(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(...),
    ),
  ),
)
```

### Form Field Accessibility
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: ''Email'',  // Used by screen readers
    hintText: ''Enter your email'',
    helperText: ''We will never share your email'',  // Read by screen readers
  ),
)
```

### Interactive Element Size
```dart
// Ensure tap targets are at least 48x48 logical pixels
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(
    icon: Icon(Icons.add),
    onPressed: _handleAdd,
  ),
)
```

### Color Contrast
- Ensure text has **4.5:1 contrast ratio** against background
- Large text (18pt+) needs **3:1 minimum**
- Use Material 3 `ColorScheme` to ensure proper contrast

---

## Widget Examples

### Example 1: Responsive Page with BLoC

```dart
import ''package:flutter/material.dart'';
import ''package:flutter_bloc/flutter_bloc.dart'';
import ''package:responsive_framework/responsive_framework.dart'';

class GuestsPage extends StatelessWidget {
  const GuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: !isLargeScreen ? AppBar(title: const Text(''Guests'')) : null,
      body: BlocBuilder<GuestsBloc, GuestsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text(''Loading...'')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (guests) => isLargeScreen
              ? LargeScreenGuestList(guests: guests)
              : SmallScreenGuestList(guests: guests),
            error: (message) => Center(
              child: Text(
                ''Error: $message'',
                style: TextStyle(color: ColorScheme.of(context).error),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGuestDialog(context),
        child: Semantics(
          label: ''Add new guest'',
          button: true,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
```

### Example 2: Themed Card Widget

```dart
class GuestCard extends StatelessWidget {
  const GuestCard({
    required this.guest,
    required this.onTap,
    super.key,
  });

  final Guest guest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: ''Guest ${guest.name}, status ${guest.rsvpStatus}'',
      button: true,
      child: Card(
        elevation: 2,
        color: colorScheme.surfaceContainer,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    guest.name[0].toUpperCase(),
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.name,
                        style: textTheme.titleMedium,
                      ),
                      if (guest.email != null)
                        Text(
                          guest.email!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(context, guest.rsvpStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, AttendanceStatus status) {
    final colorScheme = ColorScheme.of(context);
    final (color, label) = switch (status) {
      AttendanceStatus.attending => (colorScheme.primary, ''Attending''),
      AttendanceStatus.notAttending => (colorScheme.error, ''Not Attending''),
      AttendanceStatus.pending => (colorScheme.outline, ''Pending''),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}
```

### Example 3: Responsive Form

```dart
class AddGuestForm extends StatelessWidget {
  AddGuestForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameHasError = ValueNotifier(false);
  String? name;
  String? email;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
            valueListenable: nameHasError,
            builder: (context, hasError, _) {
              return TextFormField(
                decoration: InputDecoration(
                  labelText: ''Guest Name*'',
                  helperText: ''required*'',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  suffixIcon: hasError
                    ? Icon(
                        Icons.error_outline_rounded,
                        color: ColorScheme.of(context).error,
                      )
                    : null,
                ),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ''Please enter guest name'';
                  }
                  return null;
                },
                onChanged: (value) {
                  nameHasError.value = value.isEmpty;
                },
                onSaved: (value) => name = value,
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: ''Email'',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSaved: (value) => email = value,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(''Cancel''),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _handleSubmit,
                child: const Text(''Add Guest''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Dispatch to BLoC
    }
  }
}
```

### Example 4: Responsive List/Grid

```dart
class GuestListView extends StatelessWidget {
  const GuestListView({
    required this.guests,
    super.key,
  });

  final List<Guest> guests;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (isLargeScreen) {
      // Grid view for large screens
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: guests.length,
        itemBuilder: (context, index) {
          return GuestCard(
            guest: guests[index],
            onTap: () => _handleGuestTap(context, guests[index]),
          );
        },
      );
    } else {
      // List view for small screens
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: guests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return GuestCard(
            guest: guests[index],
            onTap: () => _handleGuestTap(context, guests[index]),
          );
        },
      );
    }
  }

  void _handleGuestTap(BuildContext context, Guest guest) {
    // Navigate or show details
  }
}
```

---

## Checklist

Before submitting your widget, ensure:

### Structure & Organization
- [ ] Widget type selected appropriately (StatelessWidget preferred)
- [ ] File placed in correct directory (`lib/pages/` or `lib/common/`)
- [ ] Barrel file updated if in a feature module
- [ ] Constructor uses named parameters with `super.key`

### Responsive Design
- [ ] Uses `ResponsiveBreakpoints.of(context).largerThan(TABLET)` check
- [ ] Tested on mobile viewport (< 600px)
- [ ] Tested on desktop viewport (> 840px)
- [ ] Responsive strategy appropriate for layout differences

### Theming
- [ ] Uses `ColorScheme.of(context)` for colors (Material 3)
- [ ] Uses `Theme.of(context).textTheme` for text styles
- [ ] Tested in both light and dark themes
- [ ] No hardcoded colors (except for semantic meaning)

### BLoC Integration
- [ ] BLoC provided at appropriate level (app vs page)
- [ ] Uses `BlocConsumer` for side effects + UI
- [ ] Uses `BlocBuilder` for UI-only updates
- [ ] Event dispatching uses `context.read<Bloc>()`
- [ ] State handled exhaustively with `.when()` or pattern matching

### Forms (if applicable)
- [ ] Uses `ValueNotifier` for error state indicators
- [ ] Validation with `autovalidateMode: AutovalidateMode.onUserInteraction`
- [ ] Proper `keyboardType` and `textInputAction`
- [ ] `helperText` for required fields
- [ ] Form submission validates and saves before dispatching event

### Accessibility
- [ ] Interactive elements wrapped in `Semantics` with labels
- [ ] Images have semantic labels
- [ ] Tap targets are at least 48x48 logical pixels
- [ ] Color contrast meets WCAG standards (4.5:1 for text)
- [ ] Decorative elements excluded from semantics

### Code Quality
- [ ] All imports organized (Flutter  packages  relative)
- [ ] Uses `const` constructors where possible
- [ ] No unused imports or variables
- [ ] Follows project naming conventions
- [ ] Code formatted with `dart format`

### Testing
- [ ] Widget displays correctly on mobile and desktop
- [ ] All states render correctly (loading, loaded, error)
- [ ] Form validation works as expected
- [ ] Navigation flows work correctly
- [ ] Theme switching works (light/dark)

---

## Additional Resources

- **Existing Widget Examples:**
  - [lib/common/app_shell.dart](../../lib/common/app_shell.dart) - Responsive navigation
  - [lib/common/search_app_bar.dart](../../lib/common/search_app_bar.dart) - Themed search widget
  - [lib/pages/login/login_page.dart](../../lib/pages/login/login_page.dart) - Responsive page
  - [lib/pages/login/login_form.dart](../../lib/pages/login/login_form.dart) - Form with validation
  - [lib/pages/guest_list/guest_list_page.dart](../../lib/pages/guest_list/guest_list_page.dart) - BLoC integration

- **Project Documentation:**
  - [.github/copilot-instructions.md](../copilot-instructions.md) - Full project guidelines
  - [.github/instructions/flutter.instructions.md](../instructions/flutter.instructions.md) - Flutter best practices

- **Material Design 3:**
  - [Material 3 Guidelines](https://m3.material.io/)
  - [Flutter Material 3 Migration](https://docs.flutter.dev/ui/design/material)

- **Accessibility:**
  - [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
  - [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Remember:** When in doubt, follow existing patterns in the codebase. Consistency is key!
