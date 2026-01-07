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
        path: Routes.login,
        builder: (context, state) =>
            LoginScreen(viewModel: LoginViewModel(authState: authState)),
      ),

      StatefulShellRoute(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/books',
                builder: (context, state){
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
                    name: 'create-book',
                    builder: (context, state){
                      var viewModel = CreateBookViewModel(
                        bookRepository: context.read(),
                      );
                      return CreateBookScreen(viewModel: viewModel);
                    }
                  ),
                  GoRoute(
                    path: ':bookId',
                    name: 'book-detail',
                    builder: (context, state) {
                      var viewModel = BookDetailViewModel(
                        bookRepository: context.read(),
                        recipeRepository: context.read(),
                      );
                      viewModel.loadData.execute(state.pathParameters['bookId']!);
                      return BookDetailScreen(viewModel: viewModel);
                    }
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search-recipes',
                builder: (context, state) {
                  var viewModel = SearchRecipesViewModel(
                    bookRepository: context.read(),
                    recipeRepository: context.read(),
                  );
                  viewModel.loadData.execute();
                  return SearchRecipesScreen(viewModel: viewModel);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) {
                  var viewModel = ProfileViewModel(
                    authRepository: context.read(),
                    bookRepository: context.read(),
                    recipeRepository: context.read(),
                  );
                  viewModel.loadCounts.execute();
                  return ProfileScreen(viewModel: viewModel);
                },
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
              BottomNavigationBarItem(
                icon: Icon(Icons.book), 
                label: 'Books'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              )
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
  final isLoginRoute = location == Routes.login;
  final loggedIn = await authState.isAuthenticated();

  // If not logged in and trying to access a protected route, redirect to login
  if (!loggedIn && !isLoginRoute) {
    return Routes.login;
  }

  // If logged in and on login page, redirect to home
  if (loggedIn && isLoginRoute) {
    return '/';
  }

  // Allow all other routes (including nested routes) to pass through
  return null;
}
