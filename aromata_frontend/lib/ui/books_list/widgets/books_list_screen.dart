import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/books_list_viewmodel.dart';

class BooksListScreen extends StatelessWidget {
  final BooksListViewModel viewModel;

  const BooksListScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.loadData,
      ]),
      builder: (context, child) {
        final viewModel = this.viewModel;
        return PageScaffold(
          title: 'Recipe Books',
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.pushNamed('create-book');
            },
            tooltip: 'Add Recipe Book',
            child: const Icon(Icons.add),
          ),
          child: viewModel.loadData.running
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : viewModel.books.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No recipe books yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first book',
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                          color: Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
                            title: Text(
                              book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('By ${book.author}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.pushNamed(
                                'book-detail',
                                pathParameters: {'bookId': book.id!},
                              );
                            },
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
