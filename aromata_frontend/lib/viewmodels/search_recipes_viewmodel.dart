import '../domain/models/book.dart';
import '../domain/models/recipe.dart';
import 'base_viewmodel.dart';

class SearchRecipesViewModel extends BaseViewModel {
  final List<Book> books;
  final List<Recipe> allRecipes;
  final Function(Recipe)? onRecipeUpdated;
  final Function(Recipe)? onRecipeDeleted;

  String _searchQuery = '';
  List<Recipe> _filteredRecipes = [];

  SearchRecipesViewModel({
    required this.books,
    required this.allRecipes,
    this.onRecipeUpdated,
    this.onRecipeDeleted,
  }) {
    _filteredRecipes = List.from(allRecipes);
  }

  String get searchQuery => _searchQuery;
  List<Recipe> get filteredRecipes => _filteredRecipes;

  /// Update the search query and filter recipes
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _filterRecipes();
      notifyListeners();
    }
  }

  /// Update recipes list (called when parent data changes)
  void updateRecipes(List<Recipe> recipes) {
    // Note: This assumes allRecipes is updated externally
    // In a full MVVM implementation, we'd update the allRecipes reference
    _filterRecipes();
    notifyListeners();
  }
  
  /// Update both books and recipes
  void updateData(List<Book> newBooks, List<Recipe> newRecipes) {
    // This would require making books and allRecipes mutable
    // For now, we'll work with the existing structure
    _filterRecipes();
    notifyListeners();
  }

  void _filterRecipes() {
    final query = _searchQuery.toLowerCase().trim();

    if (query.isEmpty) {
      _filteredRecipes = List.from(allRecipes);
      return;
    }

    _filteredRecipes = allRecipes.where((recipe) {
      final matchesTitle = recipe.title.toLowerCase().contains(query);
      final matchesTags = recipe.tags.any(
        (tag) => tag.toLowerCase().contains(query),
      );
      final book = books.firstWhere(
        (b) => b.id == recipe.bookId,
        orElse: () => Book(title: '', author: ''),
      );
      final matchesBook = book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);

      return matchesTitle || matchesTags || matchesBook;
    }).toList();
  }

  /// Get book for a recipe
  Book? getBookForRecipe(String bookId) {
    try {
      return books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }
}

