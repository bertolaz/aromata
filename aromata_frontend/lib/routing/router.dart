import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/services/authState.dart';
import 'package:aromata_frontend/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:aromata_frontend/ui/auth/login/widgets/login_screen.dart';
import 'package:aromata_frontend/ui/book_detail/view_models/book_detail_viewmodel.dart';
import 'package:aromata_frontend/ui/book_detail/widgets/book_detail_screen.dart';
import 'package:aromata_frontend/ui/books_list/view_models/books_list_viewmodel.dart';
import 'package:aromata_frontend/ui/books_list/widgets/books_list_screen.dart';
import 'package:aromata_frontend/ui/create_book/view_models/create_book_viewmodel.dart';
import 'package:aromata_frontend/ui/create_book/widgets/create_book_screen.dart';
import 'package:aromata_frontend/ui/create_recipe/view_models/create_recipe_viewmodel.dart';
import 'package:aromata_frontend/ui/create_recipe/widgets/create_recipe_screen.dart';
import 'package:aromata_frontend/ui/privacy_security/view_models/privacy_security_viewmodel.dart';
import 'package:aromata_frontend/ui/privacy_security/widgets/privacy_security_screen.dart';
import 'package:aromata_frontend/ui/profile/view_models/profile_viewmodel.dart';
import 'package:aromata_frontend/ui/profile/widgets/profile_screen.dart';
import 'package:aromata_frontend/ui/search_recipes/view_models/search_recipes_viewmodel.dart';
import 'package:aromata_frontend/ui/search_recipes/widgets/search_recipes_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthState authState) {
  return GoRouter(
    refreshListenable: authState,
    redirect: (context, state) => _redirect(context, state, authState),
    initialLocation: '/books',
    routes: [
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) =>
            LoginScreen(viewModel: LoginViewModel(authState: authState)),
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) {
          var viewModel = ProfileViewModel(
            authRepository: context.read(),
            bookRepository: context.read(),
            recipeRepository: context.read(),
          );
          viewModel.loadCounts.execute();
          return ProfileScreen(viewModel: viewModel);
        },
        routes: [
          GoRoute(
            path: 'privacy',
            name: RouteNames.privacy,
            builder: (context, state) {
              var viewModel = PrivacySecurityViewModel(
                authRepository: context.read(),
              );
              return PrivacySecurityScreen(viewModel: viewModel);
            },
          ),
        ],
      ),

      StatefulShellRoute(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/books',
                name: RouteNames.books,
                builder: (context, state) {
                  var viewModel = BooksListViewModel(
                    bookRepository: context.read(),
                    recipeRepository: context.read(),
                  );
                  viewModel.loadData.execute();
                  return BooksListScreen(viewModel: viewModel);
                },
                routes: [
                  GoRoute(
                    path: 'create',
                    name: RouteNames.createBook,
                    builder: (context, state) {
                      var viewModel = CreateBookViewModel(
                        bookRepository: context.read(),
                      );
                      return CreateBookScreen(viewModel: viewModel);
                    },
                  ),
                  GoRoute(
                    path: ':bookId',
                    name: RouteNames.bookDetail,
                    builder: (context, state) {
                      var viewModel = BookDetailViewModel(
                        bookRepository: context.read(),
                        recipeRepository: context.read(),
                      );
                      viewModel.loadData.execute(
                        state.pathParameters['bookId']!,
                      );
                      return BookDetailScreen(viewModel: viewModel);
                    },
                    routes: [
                      GoRoute(
                        path: 'recipes/:recipeId',
                        name: RouteNames.recipeDetail,
                        builder: (context, state) {
                          final bookId = state.pathParameters['bookId']!;
                          final recipeId = state.pathParameters.containsKey('recipeId') ? state.pathParameters['recipeId'] : null;
                          return _createRecipeScreen(context, bookId, recipeId);
                        },
                      ),
                      GoRoute(
                        path: 'recipes',
                        name: RouteNames.createRecipe,
                        builder: (context, state) {
                          final bookId = state.pathParameters['bookId']!;
                          return _createRecipeScreen(context, bookId, null);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: RouteNames.search,
                builder: (context, state) {
                  var viewModel = SearchRecipesViewModel(
                    bookRepository: context.read(),
                    recipeRepository: context.read(),
                  );
                  viewModel.loadData.execute();
                  return SearchRecipesScreen(viewModel: viewModel);
                },
                routes: [
                  GoRoute(
                    path: 'recipe',
                    name: RouteNames.searchRecipeDetail,
                    builder: (context, state) {
                      return _createRecipeScreen(context, state.uri.queryParameters['bookId']!, state.uri.queryParameters['recipeId']!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
        navigatorContainerBuilder: (context, state, child) =>
            IndexedStack(index: state.currentIndex, children: child),
        builder: (context, state, navigationShell) => Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        ),
      ),
    ],
  );
}

Future<String?> _redirect(
  BuildContext context,
  GoRouterState state,
  AuthState authState,
) async {
  final location = state.uri.path;
  final isLoginRoute = location == "/login";
  final loggedIn = await authState.isAuthenticated();

  // If not logged in and trying to access a protected route, redirect to login
  if (!loggedIn && !isLoginRoute) {
    return '/login';
  }

  // If logged in and on login page, redirect to home
  if (loggedIn && isLoginRoute) {
    return '/books';
  }

  // Allow all other routes (including nested routes) to pass through
  return null;
}


Widget _createRecipeScreen(BuildContext context, String bookId, String? recipeId) {
  var viewModel = CreateRecipeViewModel(
    recipeRepository: context.read(),
    bookId: bookId,
    initialRecipeId: recipeId,
  );
  viewModel.loadInitialRecipe.execute();
  return CreateRecipeScreen(viewModel: viewModel);
}
