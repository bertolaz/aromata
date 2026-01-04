import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/book.dart';
import '../domain/models/recipe.dart';
import '../viewmodels/search_recipes_viewmodel.dart';
import 'create_recipe_screen.dart';
import 'profile_screen.dart';

class SearchRecipesScreen extends StatefulWidget {
  final List<Book> books;
  final List<Recipe> allRecipes;
  final Function(Recipe)? onRecipeUpdated;
  final Future<void> Function(Recipe)? onRecipeDeleted;

  const SearchRecipesScreen({
    super.key,
    required this.books,
    required this.allRecipes,
    this.onRecipeUpdated,
    this.onRecipeDeleted,
  });

  @override
  State<SearchRecipesScreen> createState() => _SearchRecipesScreenState();
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  final _searchController = TextEditingController();
  late SearchRecipesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SearchRecipesViewModel(
      books: widget.books,
      allRecipes: widget.allRecipes,
      onRecipeUpdated: widget.onRecipeUpdated,
      onRecipeDeleted: widget.onRecipeDeleted,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(SearchRecipesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books != widget.books || oldWidget.allRecipes != widget.allRecipes) {
      _viewModel.updateRecipes(widget.allRecipes);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _viewModel.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SearchRecipesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Recipes'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          bookCount: widget.books.length,
                          recipeCount: widget.allRecipes.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by recipe name, tags, book, or author...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: viewModel.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                // Results
                Expanded(
                  child: viewModel.filteredRecipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                viewModel.searchQuery.isEmpty
                                    ? Icons.search
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.searchQuery.isEmpty
                                    ? 'Search for recipes'
                                    : 'No recipes found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (viewModel.searchQuery.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching by recipe name, tags, book title, or author',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.filteredRecipes.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final recipe = viewModel.filteredRecipes[index];
                            final book = viewModel.getBookForRecipe(recipe.bookId);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    recipe.page.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                title: Text(
                                  recipe.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (book != null)
                                      Text(
                                        '${book.title} by ${book.author}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    Text('Page ${recipe.page}'),
                                    if (recipe.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: recipe.tags.map(
                                          (tag) => Chip(
                                            label: Text(
                                              tag,
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ).toList(),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  if (book != null) {
                                    final updatedRecipe = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateRecipeScreen(
                                          bookId: book.id!,
                                          recipe: recipe,
                                          onRecipeDeleted: widget.onRecipeDeleted,
                                        ),
                                      ),
                                    );
                                    if (updatedRecipe != null) {
                                      // Notify parent of the update
                                      widget.onRecipeUpdated?.call(updatedRecipe);
                                      // Re-filter to show updated data
                                      viewModel.updateRecipes(widget.allRecipes);
                                    } else {
                                      // Recipe might have been deleted, refresh
                                      viewModel.updateRecipes(widget.allRecipes);
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

