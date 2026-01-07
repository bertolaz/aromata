import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/repositories/recipe_repository.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:aromata_frontend/ui/auth/login/widgets/login_screen.dart';
import 'package:aromata_frontend/ui/books_list/view_models/books_list_viewmodel.dart';
import 'package:aromata_frontend/ui/books_list/widgets/books_list_screen.dart';
import 'package:aromata_frontend/ui/book_detail/view_models/book_detail_viewmodel.dart';
import 'package:aromata_frontend/ui/book_detail/widgets/book_detail_screen.dart';
import 'package:aromata_frontend/ui/create_book/view_models/create_book_viewmodel.dart';
import 'package:aromata_frontend/ui/create_book/widgets/create_book_screen.dart';
import 'package:aromata_frontend/ui/profile/view_models/profile_viewmodel.dart';
import 'package:aromata_frontend/ui/profile/widgets/profile_screen.dart';
import 'package:aromata_frontend/ui/search_recipes/view_models/search_recipes_viewmodel.dart';
import 'package:aromata_frontend/ui/search_recipes/widgets/search_recipes_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) {
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authRepository,
    redirect: (context, state) => _redirect(context, state, authRepository),
    routes: [
      /// ----------------------
      /// LOGIN (no bottom nav)
      /// ----------------------
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          return LoginScreen(
            viewModel: LoginViewModel(authRepository: authRepository),
          );
        },
      ),

      /// ----------------------
      /// MAIN APP SHELL
      /// ----------------------
      StatefulShellRoute(
        navigatorContainerBuilder: (context, state, widgets) {
          return IndexedStack(index: state.currentIndex, children: widgets);
        },
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.books,
                builder: (context, state) {
                  return BooksListScreen(
                    viewModel: BooksListViewModel(
                      bookRepository: context.read<BookRepository>(),
                      recipeRepository: context.read<RecipeRepository>(),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':bookId',
                    name: 'book-detail',
                    builder: (context, state) {
                      return BookDetailScreen(
                        viewModel: BookDetailViewModel(
                          bookRepository: context.read<BookRepository>(),
                          recipeRepository: context.read<RecipeRepository>(),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'create',
                    name: 'create-book',
                    builder: (context, state) {
                      return CreateBookScreen(
                        viewModel: CreateBookViewModel(
                          bookRepository: context.read<BookRepository>(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (context, state) {
                  return SearchRecipesScreen(
                    viewModel: SearchRecipesViewModel(
                      bookRepository: context.read<BookRepository>(),
                      recipeRepository: context.read<RecipeRepository>(),
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) {
                  return ProfileScreen(
                    viewModel: ProfileViewModel(
                      authRepository: authRepository,
                      bookRepository: context.read<BookRepository>(),
                      recipeRepository: context.read<RecipeRepository>(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Future<String?> _redirect(
  BuildContext context,
  GoRouterState state,
  AuthRepository authRepository,
) async {
  final loggedIn = await authRepository.isAuthenticated();
  final loggingIn = state.matchedLocation == Routes.login;

  if (!loggedIn) return Routes.login;
  if (loggingIn) return Routes.books;

  return null;
}
