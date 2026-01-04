import '../domain/models/book.dart';
import '../domain/models/recipe.dart';
import 'base_viewmodel.dart';

class BookDetailViewModel extends BaseViewModel {
  final Book book;
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeAdded;
  final Function(Recipe) onRecipeUpdated;
  final Function(Recipe) onRecipeDeleted;

  List<Recipe> _sortedRecipes = [];

  BookDetailViewModel({
    required this.book,
    required this.recipes,
    required this.onRecipeAdded,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  }) {
    _updateSortedRecipes();
  }

  List<Recipe> get sortedRecipes => _sortedRecipes;

  void _updateSortedRecipes() {
    _sortedRecipes = List.from(recipes);
    _sortedRecipes.sort((a, b) => a.page.compareTo(b.page));
    notifyListeners();
  }

  void updateRecipes(List<Recipe> newRecipes) {
    // Note: This assumes recipes list is updated externally
    // In a full MVVM implementation, we'd update the recipes reference
    _updateSortedRecipes();
    notifyListeners();
  }

  int get recipeCount => _sortedRecipes.length;
}

