import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:yjm_wedding_guest_management/app_shell.dart';

import 'home_page.dart';

part 'routes.g.dart';

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  routes: $appRoutes,
  // initialLocation: FirebaseAuth.instance.currentUser == null ? '/login' : '/',
  initialLocation: '/home',
);

@TypedShellRoute<AppShellRouteData>(
  routes: <TypedRoute<RouteData>>[TypedGoRoute<HomeRouteData>(path: '/home')],
)
@immutable
class AppShellRouteData extends ShellRouteData {
  const AppShellRouteData();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;
  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AppShell(child: navigator);
  }
}

class HomeRouteData extends GoRouteData with $HomeRouteData {
  const HomeRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}
