import '../domain/models/book.dart';
import '../domain/models/recipe.dart';
import '../repositories/book_repository.dart';
import '../repositories/recipe_repository.dart';
import 'base_viewmodel.dart';

class MainNavigationViewModel extends BaseViewModel {
  late final IBookRepository _bookRepository;
  late final IRecipeRepository _recipeRepository;

  MainNavigationViewModel({
    required IBookRepository bookRepository,
    required IRecipeRepository recipeRepository,
  })  : _bookRepository = bookRepository,
        _recipeRepository = recipeRepository;

  List<Book> _books = [];
  List<Recipe> _allRecipes = [];
  int _currentIndex = 0;

  List<Book> get books => _books;
  List<Recipe> get allRecipes => _allRecipes;
  int get currentIndex => _currentIndex;

  /// Load all data (books and recipes)
  Future<void> loadData() async {
    await execute(() async {
      final books = await _bookRepository.getBooks();
      final recipes = await _recipeRepository.getAllRecipes();
      _books = books;
      _allRecipes = recipes;
      notifyListeners();
    });
  }

  /// Add a new book
  Future<void> addBook(Book book) async {
    await execute(() async {
      await _bookRepository.createBook(book.title, book.author);
      await loadData();
    });
  }

  /// Update an existing book
  Future<void> updateBook(Book book) async {
    await execute(() async {
      await _bookRepository.updateBook(book.id!, book.title, book.author);
      await loadData();
    });
  }

  /// Delete a book
  Future<void> deleteBook(Book book) async {
    await execute(() async {
      await _bookRepository.deleteBook(book.id!);
      await loadData();
    });
  }

  /// Add a new recipe
  Future<void> addRecipe(Recipe recipe) async {
    await execute(() async {
      await _recipeRepository.createRecipe(
        recipe.bookId,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await loadData();
    });
  }

  /// Update an existing recipe
  Future<void> updateRecipe(Recipe recipe) async {
    await execute(() async {
      await _recipeRepository.updateRecipe(
        recipe.id!,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await loadData();
    });
  }

  /// Delete a recipe
  Future<void> deleteRecipe(Recipe recipe) async {
    await execute(() async {
      await _recipeRepository.deleteRecipe(recipe.id!);
      await loadData();
    });
  }

  /// Change the current navigation index
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Get recipes for a specific book
  List<Recipe> getRecipesForBook(String bookId) {
    return _allRecipes.where((r) => r.bookId == bookId).toList();
  }
}

