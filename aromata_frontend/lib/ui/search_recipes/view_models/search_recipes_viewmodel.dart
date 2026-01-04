import '../../../domain/models/book.dart';
import '../../../domain/models/recipe.dart';
import '../../../viewmodels/base_viewmodel.dart';
import '../../../repositories/book_repository.dart';
import '../../../repositories/recipe_repository.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';

class SearchRecipesViewModel extends BaseViewModel {
  final BookRepository _bookRepository;
  final RecipeRepository _recipeRepository;

  String _searchQuery = '';
  List<Recipe> _allRecipes = [];
  List<Book> _books = [];
  List<Recipe> _filteredRecipes = [];

  late final Command0<void> loadData;

  SearchRecipesViewModel({
    required BookRepository bookRepository,
    required RecipeRepository recipeRepository,
  })  : _bookRepository = bookRepository,
        _recipeRepository = recipeRepository {
    loadData = Command0<void>(_loadData);
  }

  String get searchQuery => _searchQuery;
  List<Recipe> get filteredRecipes => _filteredRecipes;
  List<Book> get books => _books;
  List<Recipe> get allRecipes => _allRecipes;

  Future<Result<void>> _loadData() async {
    try {
      _books = await _bookRepository.getBooks();
      _allRecipes = await _recipeRepository.getAllRecipes();
      _filterRecipes();
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load data: $e'));
    }
  }

  /// Update the search query and filter recipes
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _filterRecipes();
      notifyListeners();
    }
  }

  /// Refresh recipes from repositories
  Future<void> refreshRecipes() async {
    await _loadData();
  }

  void _filterRecipes() {
    final query = _searchQuery.toLowerCase().trim();

    if (query.isEmpty) {
      _filteredRecipes = List.from(_allRecipes);
      return;
    }

    _filteredRecipes = _allRecipes.where((recipe) {
      final matchesTitle = recipe.title.toLowerCase().contains(query);
      final matchesTags = recipe.tags.any(
        (tag) => tag.toLowerCase().contains(query),
      );
      final book = _books.firstWhere(
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
      return _books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }
}

