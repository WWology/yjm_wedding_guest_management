import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'bloc_observer.dart';
import 'firebase_options.dart';
import 'modules/modules.dart';
import 'routes.dart';
import 'theme.dart';
import 'util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  usePathUrlStrategy();
  final authService = AuthService();

  Bloc.observer = const AppBlocObserver();
  runApp(App(authService: authService));
}

class App extends StatelessWidget {
  final AuthService authService;

  const App({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final textTheme = createTextTheme(context, "Roboto", "Roboto");
    final theme = MaterialTheme(textTheme);

    return BlocProvider(
      lazy: false,
      create: (_) =>
          AuthBloc(authService: authService)
            ..add(const .userSubscriptionRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) => router.refresh(),
        child: MaterialApp.router(
          routerConfig: router,
          title: 'Flutter Demo',
          theme: brightness == Brightness.light ? theme.light() : theme.dark(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            breakpoints: [
              const Breakpoint(start: 0, end: 599, name: MOBILE),
              const Breakpoint(start: 600, end: 839, name: TABLET),
              const Breakpoint(start: 840, end: 1199, name: DESKTOP),
              const Breakpoint(start: 1200, end: 1599, name: 'Large'),
              const Breakpoint(start: 1600, end: double.infinity, name: 'XL'),
            ],
            child: child!,
          ),
        ),
      ),
    );
  }
}
