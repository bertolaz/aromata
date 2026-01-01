import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/recipe.dart';
import '../screens/create_recipe_screen.dart';
import '../screens/bulk_import_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final List<Recipe> recipes;
  final Future<void> Function(Recipe) onRecipeAdded;
  final Future<void> Function(Recipe) onRecipeUpdated;
  final Future<void> Function(Recipe) onRecipeDeleted;
  final Future<void> Function(Book) onBookDeleted;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.recipes,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
    required this.onBookDeleted,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late List<Recipe> _recipes;
  
  @override
  void initState() {
    super.initState();
    _recipes = List.from(widget.recipes);
    _recipes.sort((a, b) => a.page.compareTo(b.page));
  }

  @override
  void didUpdateWidget(BookDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipes != widget.recipes) {
      _recipes = List.from(widget.recipes);
      _recipes.sort((a, b) => a.page.compareTo(b.page));
    }
  }

  void _deleteBook() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${widget.book.title}"? This will also delete all recipes in this book. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                widget.onBookDeleted(widget.book);
                Navigator.of(context).pop(); // Navigate back to books list
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Book',
            onPressed: _deleteBook,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
      body: Column(
        children: [
          // Book info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.book.author,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_recipes.length} recipe${_recipes.length != 1 ? 's' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          // Recipes list
          Expanded(
            child: _recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first recipe',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _recipes.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
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
                          subtitle: recipe.tags.isEmpty
                              ? Text('Page ${recipe.page}')
                              : Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    Text('Page ${recipe.page}'),
                                    const Text(' • '),
                                    ...recipe.tags.map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                  ],
                                ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final updatedRecipe = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateRecipeScreen(
                                  bookId: widget.book.id!,
                                  recipe: recipe,
                                  onRecipeDeleted: widget.onRecipeDeleted,
                                ),
                              ),
                            );
                            if (updatedRecipe != null) {
                              widget.onRecipeUpdated(updatedRecipe);
                              setState(() {
                                final index = _recipes.indexWhere(
                                  (r) => r.id == recipe.id,
                                );
                                if (index != -1) {
                                  _recipes[index] = updatedRecipe;
                                }
                              });
                            } else {
                              // Recipe might have been deleted, refresh the list
                              setState(() {
                                _recipes.removeWhere((r) => r.id == recipe.id);
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () async {
              final importedRecipes = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BulkImportScreen(
                    bookId: widget.book.id!,
                    onRecipesImported: (recipes) {
                      for (final recipe in recipes) {
                        widget.onRecipeAdded(recipe);
                      }
                    },
                  ),
                ),
              );
              if (importedRecipes != null && importedRecipes.isNotEmpty) {
                setState(() {
                  _recipes.addAll(importedRecipes);
                  _recipes.sort((a, b) => a.page.compareTo(b.page));
                });
              }
            },
            tooltip: 'Bulk Import',
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              final newRecipe = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRecipeScreen(
                    bookId: widget.book.id!,
                  ),
                ),
              );
              if (newRecipe != null) {
                widget.onRecipeAdded(newRecipe);
                setState(() {
                  _recipes.add(newRecipe);
                  _recipes.sort((a, b) => a.page.compareTo(b.page));
                });
              }
            },
            tooltip: 'Add Recipe',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

