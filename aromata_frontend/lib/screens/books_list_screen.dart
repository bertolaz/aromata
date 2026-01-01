import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/recipe.dart';
import '../screens/book_detail_screen.dart';
import '../screens/create_book_screen.dart';
import '../screens/profile_screen.dart';

class BooksListScreen extends StatefulWidget {
  final List<Book> books;
  final List<Recipe> allRecipes;
  final Future<void> Function(Book) onBookAdded;
  final Future<void> Function(Book) onBookUpdated;
  final Future<void> Function(Book) onBookDeleted;
  final Future<void> Function(Recipe) onRecipeAdded;
  final Future<void> Function(Recipe) onRecipeUpdated;
  final Future<void> Function(Recipe) onRecipeDeleted;

  const BooksListScreen({
    super.key,
    required this.books,
    required this.allRecipes,
    required this.onBookAdded,
    required this.onBookUpdated,
    required this.onBookDeleted,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  });

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Books'),
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
      body: widget.books.isEmpty
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
              itemCount: widget.books.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final book = widget.books[index];
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(
                            book: book,
                            recipes: widget.allRecipes
                                .where((r) => r.bookId == book.id)
                                .toList(),
                            onRecipeAdded: widget.onRecipeAdded,
                            onRecipeUpdated: widget.onRecipeUpdated,
                            onRecipeDeleted: widget.onRecipeDeleted,
                            onBookDeleted: widget.onBookDeleted,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateBookScreen(),
            ),
          );
          if (newBook != null) {
            // Save book to Supabase (async)
            await widget.onBookAdded(newBook);
            // Wait a bit for the data to reload, then find the new book
            await Future.delayed(const Duration(milliseconds: 100));
            // Find the newly created book from the updated list
            final createdBook = widget.books.firstWhere(
              (b) => b.title == newBook.title && b.author == newBook.author,
              orElse: () => newBook,
            );
            // Navigate to the book detail screen
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(
                  book: createdBook,
                  recipes: widget.allRecipes
                      .where((r) => r.bookId == createdBook.id)
                      .toList(),
                  onRecipeAdded: widget.onRecipeAdded,
                  onRecipeUpdated: widget.onRecipeUpdated,
                  onRecipeDeleted: widget.onRecipeDeleted,
                  onBookDeleted: widget.onBookDeleted,
                ),
              ),
            );
          }
        },
        tooltip: 'Add Recipe Book',
        child: const Icon(Icons.add),
      ),
    );
  }
}

