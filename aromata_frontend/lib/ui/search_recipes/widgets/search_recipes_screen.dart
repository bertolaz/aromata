import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/search_recipes_viewmodel.dart';

class SearchRecipesScreen extends StatefulWidget {
  final SearchRecipesViewModel viewModel;

  const SearchRecipesScreen({super.key, required this.viewModel});

  @override
  State<SearchRecipesScreen> createState() => _SearchRecipesScreenState();
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    widget.viewModel.loadData.execute();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.viewModel.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Search Recipes'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: 'Profile',
                onPressed: () {
                  context.push(Routes.profile);
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
                child: widget.viewModel.filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.viewModel.searchQuery.isEmpty
                                  ? 'Start typing to search recipes'
                                  : 'No recipes found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.viewModel.filteredRecipes.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final recipe =
                              widget.viewModel.filteredRecipes[index];
                          final book = widget.viewModel.getBookForRecipe(
                            recipe.bookId,
                          );
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
                                      '${book.title} - Page ${recipe.page}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (recipe.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: recipe.tags
                                          .map(
                                            (tag) => Chip(
                                              label: Text(
                                                tag,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.push(Routes.recipeWithId(recipe.id!));
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
    );
  }
}
