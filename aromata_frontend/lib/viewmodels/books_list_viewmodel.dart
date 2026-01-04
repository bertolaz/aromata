import '../domain/models/book.dart';
import '../domain/models/recipe.dart';
import 'base_viewmodel.dart';

class BooksListViewModel extends BaseViewModel {
  final List<Book> books;
  final List<Recipe> allRecipes;
  final Function(Book) onBookAdded;
  final Function(Book) onBookUpdated;
  final Function(Book) onBookDeleted;
  final Function(Recipe) onRecipeAdded;
  final Function(Recipe) onRecipeUpdated;
  final Function(Recipe) onRecipeDeleted;

  BooksListViewModel({
    required this.books,
    required this.allRecipes,
    required this.onBookAdded,
    required this.onBookUpdated,
    required this.onBookDeleted,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  });

  /// Get recipes for a specific book
  List<Recipe> getRecipesForBook(String bookId) {
    return allRecipes.where((r) => r.bookId == bookId).toList();
  }
}

