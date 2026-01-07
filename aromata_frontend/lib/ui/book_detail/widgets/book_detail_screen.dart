import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/book_detail_viewmodel.dart';

class BookDetailScreen extends StatefulWidget {
  final BookDetailViewModel viewModel;

  const BookDetailScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.deleteBook.addListener(_onBookDeleted);
  }

  @override
  void dispose() {
    widget.viewModel.deleteBook.removeListener(_onBookDeleted);
    super.dispose();
  }

  void _onBookDeleted() {
    if (widget.viewModel.deleteBook.completed) {
      widget.viewModel.deleteBook.clearResult();
      if (mounted) {
        context.pop();
      }
    }
  }

  void _deleteBook() {
    final book = widget.viewModel.book;
    if (book == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${book.title}"? This will also delete all recipes in this book. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.viewModel.deleteBook.execute(book);
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        final book = viewModel.book;
        if (book == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
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
                      book.title,
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
                          book.author,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${viewModel.recipeCount} recipe${viewModel.recipeCount != 1 ? 's' : ''}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              // Recipes list
              Expanded(
                child: viewModel.sortedRecipes.isEmpty
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
                        itemCount: viewModel.sortedRecipes.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final recipe = viewModel.sortedRecipes[index];
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
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.recipeDetail,
                                  pathParameters: {'bookId': book.id!, 'recipeId': recipe.id!},
                                );
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
                onPressed: () {
                  context.pushNamed(
                    RouteNames.bulkImport,
                    pathParameters: {'bookId': book.id!},
                  );
                },
                tooltip: 'Bulk Import',
                child: const Icon(Icons.camera_alt),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                heroTag: 'add',
                onPressed: () {
                  context.pushNamed(
                    RouteNames.createRecipe,
                    pathParameters: {'bookId': book.id!},
                  );
                },
                tooltip: 'Add Recipe',
                child: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}

