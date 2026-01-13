import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'pages/pages.dart';
import 'common/app_shell.dart';
import 'modules/modules.dart';

part 'routes.g.dart';

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  routes: $appRoutes,
  initialLocation: '/home',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final inLoginPage = state.matchedLocation == LoginRoute().location;

    // Redirect to Login page if not authenticated & not already in Login page
    if (authState is! Authenticated && !inLoginPage) {
      return LoginRoute().location;
    }

    // Redirect to Home page if authenticated & in Login page
    if (authState is Authenticated && inLoginPage) {
      return HomeRoute().location;
    }
    return null;
  },
);

@TypedShellRoute<AppShellRoute>(
  routes: <TypedRoute<RouteData>>[TypedGoRoute<HomeRoute>(path: '/home')],
)
@immutable
class AppShellRoute extends ShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppShell(child: navigator);
  }
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GuestListPage();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}
