import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/repositories/recipe_repository.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:aromata_frontend/ui/auth/login/widgets/login_screen.dart';
import 'package:aromata_frontend/ui/books_list/view_models/books_list_viewmodel.dart';
import 'package:aromata_frontend/ui/books_list/widgets/books_list_screen.dart';
import 'package:aromata_frontend/ui/main_navigation/view_models/main_navigation_viewmodel.dart';
import 'package:aromata_frontend/ui/main_navigation/widgets/main_navigation_screen.dart';
import 'package:aromata_frontend/ui/book_detail/view_models/book_detail_viewmodel.dart';
import 'package:aromata_frontend/ui/book_detail/widgets/book_detail_screen.dart';
import 'package:aromata_frontend/ui/create_book/view_models/create_book_viewmodel.dart';
import 'package:aromata_frontend/ui/create_book/widgets/create_book_screen.dart';
import 'package:aromata_frontend/ui/create_recipe/view_models/create_recipe_viewmodel.dart';
import 'package:aromata_frontend/ui/create_recipe/widgets/create_recipe_screen.dart';
import 'package:aromata_frontend/ui/profile/view_models/profile_viewmodel.dart';
import 'package:aromata_frontend/ui/profile/widgets/profile_screen.dart';
import 'package:aromata_frontend/ui/privacy_security/view_models/privacy_security_viewmodel.dart';
import 'package:aromata_frontend/ui/privacy_security/widgets/privacy_security_screen.dart';
import 'package:aromata_frontend/ui/bulk_import/view_models/bulk_import_viewmodel.dart';
import 'package:aromata_frontend/ui/bulk_import/widgets/bulk_import_screen.dart';
import 'package:aromata_frontend/ui/search_recipes/view_models/search_recipes_viewmodel.dart';
import 'package:aromata_frontend/ui/search_recipes/widgets/search_recipes_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) {
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authRepository,
    redirect: (context, state) => _redirect(
      context,
      state,
      authRepository,
    ),
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
      ShellRoute(
        builder: (context, state, child) {
          final viewModel = MainNavigationViewModel(
          );

          return ChangeNotifierProvider.value(
            value: viewModel,
            child: MainNavigationScreen(
              viewModel: viewModel,
              child: child,
            ),
          );
        },
        routes: [
          /// BOOKS TAB
          GoRoute(
            path: Routes.books,
            builder: (context, state) {
              final viewModel = BooksListViewModel(
                bookRepository: context.read<BookRepository>(),
                recipeRepository: context.read<RecipeRepository>(),
              );
              viewModel.loadData.execute();
              return BooksListScreen(viewModel: viewModel);
            },
            routes: [
              GoRoute(
                path: ':bookId',
                builder: (context, state) {
                  final bookId = state.pathParameters['bookId']!;
                  final viewModel = BookDetailViewModel(
                    bookRepository: context.read<BookRepository>(),
                    recipeRepository: context.read<RecipeRepository>(),
                  );
                  viewModel.loadData.execute(bookId);
                  return BookDetailScreen(viewModel: viewModel);
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final viewModel = CreateBookViewModel(
                    bookRepository: context.read<BookRepository>(),
                  );
                  return CreateBookScreen(viewModel: viewModel);
                },
              ),
            ],
          ),

          /// SEARCH TAB
          GoRoute(
            path: Routes.search,
            builder: (context, state) {
              final viewModel = SearchRecipesViewModel(
                bookRepository: context.read<BookRepository>(),
                recipeRepository: context.read<RecipeRepository>(),
              );
              return SearchRecipesScreen(viewModel: viewModel);
            },
          ),

          /// RECIPES
          GoRoute(
            path: Routes.recipes,
            builder: (context, state) {
              final viewModel = CreateRecipeViewModel(
                bookId: state.uri.queryParameters['bookId']!,
                recipeRepository: context.read<RecipeRepository>(),
              );
              return CreateRecipeScreen(viewModel: viewModel);
            },
            routes: [
              GoRoute(
                path: ':recipeId',
                builder: (context, state) {
                  final recipeId = state.pathParameters['recipeId']!;
                  final bookId = state.uri.queryParameters['bookId']!;
                  final viewModel = CreateRecipeViewModel(
                    bookId: bookId,
                    recipeRepository: context.read<RecipeRepository>(),
                  );

                  Future.microtask(() async {
                    final recipe = await context
                        .read<RecipeRepository>()
                        .getRecipeById(recipeId);
                    if (recipe != null) {
                      viewModel.setInitialRecipe(recipe);
                    }
                  });

                  return CreateRecipeScreen(viewModel: viewModel);
                },
              ),
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final bookId = state.uri.queryParameters['bookId']!;
                  final viewModel = CreateRecipeViewModel(
                    bookId: bookId,
                    recipeRepository: context.read<RecipeRepository>(),
                  );
                  return CreateRecipeScreen(viewModel: viewModel);
                },
              ),
              GoRoute(
                path: 'bulk-import',
                builder: (context, state) {
                  final bookId = state.uri.queryParameters['bookId']!;
                  final viewModel = BulkImportViewModel(
                    bookId: bookId,
                    recipeRepository: context.read<RecipeRepository>(),
                  );
                  return BulkImportScreen(viewModel: viewModel);
                },
              ),
            ],
          ),
        ],
      ),

      /// ----------------------
      /// PROFILE (outside shell)
      /// ----------------------
      GoRoute(
        path: Routes.profile,
        builder: (context, state) {
          final viewModel = ProfileViewModel(
            authRepository: authRepository,
            bookRepository: context.read(),
            recipeRepository: context.read(),
          );
          viewModel.loadCounts.execute();
          return ProfileScreen(viewModel: viewModel);
        },
      ),

      /// ----------------------
      /// PRIVACY
      /// ----------------------
      GoRoute(
        path: Routes.privacy,
        builder: (context, state) {
          final viewModel = PrivacySecurityViewModel(
            authRepository: authRepository,
          );
          return PrivacySecurityScreen(viewModel: viewModel);
        },
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
