import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/repositories/recipe_repository.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:aromata_frontend/ui/auth/login/widgets/login_screen.dart';
import 'package:aromata_frontend/ui/books_list/widgets/books_list_screen.dart';
import 'package:aromata_frontend/ui/books_list/view_models/books_list_viewmodel.dart';
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
import 'package:aromata_frontend/ui/search_recipes/widgets/search_recipes_screen.dart';
import 'package:aromata_frontend/ui/search_recipes/view_models/search_recipes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(
  AuthRepository authRepository
) {
  return GoRouter(
    initialLocation: Routes.login,
    refreshListenable: authRepository,
    redirect: (context, state) => _redirect(
      context,
      state,
      authRepository,
    ),
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          return LoginScreen(
            viewModel: LoginViewModel(authRepository: authRepository),
          );
        },
      ),
      GoRoute(
        path: Routes.home,
        redirect: (context, state) => Routes.books,
        builder: (context, state) {
          final viewModel = MainNavigationViewModel(
            bookRepository: context.read<BookRepository>(),
            recipeRepository: context.read<RecipeRepository>(),
          );
          return ChangeNotifierProvider.value(
            value: viewModel,
            child: MainNavigationScreen(viewModel: viewModel),
          );
        },
        routes: [
          GoRoute(
            path: Routes.books,
            builder: (context, state) {
              final booksListViewModel = BooksListViewModel(
                bookRepository: context.read<BookRepository>(),
                recipeRepository: context.read<RecipeRepository>(),
              );
              return BooksListScreen(viewModel: booksListViewModel);
            },
            routes: [
              GoRoute(
                path: ':bookId',
                builder: (context, state) {
                  final bookId = state.pathParameters['bookId']!;
                  var viewModel = BookDetailViewModel(
                    bookRepository: context.read<BookRepository>(),
                    recipeRepository: context.read<RecipeRepository>(),
                  );
                  viewModel.loadData.execute(bookId);
                  return BookDetailScreen(viewModel: viewModel);
                },
              ),
              GoRoute(
                path: Routes.createBook,
                builder: (context, state) {
                  final viewModel = CreateBookViewModel(
                    bookRepository: context.read<BookRepository>(),
                  );
                  return CreateBookScreen(viewModel: viewModel);
                },
              ),
            ],
          ),
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
          GoRoute(
            path: Routes.recipes,
            builder: (context, state) {
              final recipeId = state.pathParameters['recipeId']!;
              final bookId = state.uri.queryParameters['bookId']!;
              // Load recipe synchronously - we'll need to handle this differently
              // For now, create without initial recipe and load it
              final viewModel = CreateRecipeViewModel(
                bookId: bookId,
                recipeRepository: context.read<RecipeRepository>(),
              );
              // Load recipe asynchronously after screen is built
              Future.microtask(() async {
                final recipe = await context.read<RecipeRepository>().getRecipeById(recipeId);
                if (recipe != null) {
                  viewModel.setInitialRecipe(recipe);
                }
              });
              return CreateRecipeScreen(viewModel: viewModel);
            },
          ),
          GoRoute(
            path: 'create-recipe',
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
      GoRoute(
        path: Routes.profile,
        builder: (context, state) {
          final viewModel = ProfileViewModel(
            authRepository: authRepository,
            bookRepository: context.read<BookRepository>(),
            recipeRepository: context.read<RecipeRepository>(),
          );
          viewModel.loadCounts.execute();
          return ProfileScreen(viewModel: viewModel);
        },
      ),
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

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(
  BuildContext context,
  GoRouterState state,
  AuthRepository authRepository,
) async {
  // if the user is not logged in, they need to login
  var loggedIn = await authRepository.isAuthenticated();
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
