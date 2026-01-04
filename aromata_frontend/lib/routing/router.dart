import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:aromata_frontend/ui/auth/login/widgets/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(IAuthRepository authRepository) {
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authRepository,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          return LoginScreen(viewModel: LoginViewModel(authRepository: authRepository));
        },
      ),
    ],
  );
}

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  var loggedIn = await context.read<IAuthRepository>().isAuthenticated();
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.login;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}