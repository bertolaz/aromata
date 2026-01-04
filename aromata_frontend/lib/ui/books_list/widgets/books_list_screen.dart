import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/books_list_viewmodel.dart';

class BooksListScreen extends StatelessWidget {
  final BooksListViewModel viewModel;

  const BooksListScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<BooksListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Recipe Books'),
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
            body: viewModel.books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipe books yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first book',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: viewModel.books.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final book = viewModel.books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.menu_book),
                          title: Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('By ${book.author}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(
                              '${Routes.home}/books/${book.id}',
                              extra: book,
                            );
                          },
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push(Routes.createBook);
              },
              tooltip: 'Add Recipe Book',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

