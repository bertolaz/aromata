import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_navigation_viewmodel.dart';
import 'books_list_screen.dart';
import 'search_recipes_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNavigationViewModel?>(
      builder: (context, viewModel, child) {
        if (viewModel == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (viewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (viewModel.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage ?? 'An error occurred',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: viewModel.currentIndex,
            children: [
              BooksListScreen(
                books: viewModel.books,
                allRecipes: viewModel.allRecipes,
                onBookAdded: (book) => viewModel.addBook(book),
                onBookUpdated: (book) => viewModel.updateBook(book),
                onBookDeleted: (book) => viewModel.deleteBook(book),
                onRecipeAdded: (recipe) => viewModel.addRecipe(recipe),
                onRecipeUpdated: (recipe) => viewModel.updateRecipe(recipe),
                onRecipeDeleted: (recipe) => viewModel.deleteRecipe(recipe),
              ),
              SearchRecipesScreen(
                key: ValueKey('search_${viewModel.allRecipes.length}_${viewModel.books.length}'),
                books: viewModel.books,
                allRecipes: viewModel.allRecipes,
                onRecipeUpdated: (recipe) => viewModel.updateRecipe(recipe),
                onRecipeDeleted: (recipe) => viewModel.deleteRecipe(recipe),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: viewModel.currentIndex,
            onDestinationSelected: (index) => viewModel.setCurrentIndex(index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Books',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        );
      },
    );
  }
}
