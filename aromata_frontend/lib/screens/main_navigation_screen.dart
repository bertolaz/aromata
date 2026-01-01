import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/recipe.dart';
import '../services/supabase_service.dart';
import 'books_list_screen.dart';
import 'search_recipes_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final SupabaseService _supabaseService = SupabaseService();
  
  // Shared state for books and recipes
  List<Book> _books = [];
  List<Recipe> _allRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final books = await _supabaseService.getBooks();
      final recipes = await _supabaseService.getAllRecipes();

      setState(() {
        _books = books;
        _allRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addBook(Book book) async {
    try {
      await _supabaseService.createBook(book.title, book.author);
      await _loadData(); // Reload to get the new book with ID
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateBook(Book book) async {
    try {
      await _supabaseService.updateBook(book.id!, book.title, book.author);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addRecipe(Recipe recipe) async {
    try {
      await _supabaseService.createRecipe(
        recipe.bookId,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRecipe(Recipe recipe) async {
    try {
      await _supabaseService.updateRecipe(
        recipe.id!,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    try {
      await _supabaseService.deleteRecipe(recipe.id!);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteBook(Book book) async {
    try {
      await _supabaseService.deleteBook(book.id!);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BooksListScreenWrapper(
            books: _books,
            allRecipes: _allRecipes,
            onBookAdded: _addBook,
            onBookUpdated: _updateBook,
            onBookDeleted: _deleteBook,
            onRecipeAdded: _addRecipe,
            onRecipeUpdated: _updateRecipe,
            onRecipeDeleted: _deleteRecipe,
          ),
          SearchRecipesScreen(
            key: ValueKey('search_${_allRecipes.length}_${_books.length}'),
            books: _books,
            allRecipes: _allRecipes,
            onRecipeUpdated: _updateRecipe,
            onRecipeDeleted: _deleteRecipe,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
  }
}

// Wrapper to pass callbacks to BooksListScreen
class BooksListScreenWrapper extends StatefulWidget {
  final List<Book> books;
  final List<Recipe> allRecipes;
  final Future<void> Function(Book) onBookAdded;
  final Future<void> Function(Book) onBookUpdated;
  final Future<void> Function(Book) onBookDeleted;
  final Future<void> Function(Recipe) onRecipeAdded;
  final Future<void> Function(Recipe) onRecipeUpdated;
  final Future<void> Function(Recipe) onRecipeDeleted;

  const BooksListScreenWrapper({
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
  State<BooksListScreenWrapper> createState() =>
      _BooksListScreenWrapperState();
}

class _BooksListScreenWrapperState
    extends State<BooksListScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return BooksListScreen(
      books: widget.books,
      allRecipes: widget.allRecipes,
      onBookAdded: widget.onBookAdded,
      onBookUpdated: widget.onBookUpdated,
      onBookDeleted: widget.onBookDeleted,
      onRecipeAdded: widget.onRecipeAdded,
      onRecipeUpdated: widget.onRecipeUpdated,
      onRecipeDeleted: widget.onRecipeDeleted,
    );
  }
}

