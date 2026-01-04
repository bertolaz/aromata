import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/recipe.dart';
import '../../../repositories/book_repository.dart';
import '../../../repositories/recipe_repository.dart';
import '../../../viewmodels/base_viewmodel.dart';

class MainNavigationViewModel extends BaseViewModel {
  final BookRepository _bookRepository;
  final RecipeRepository _recipeRepository;

  List<Book> _books = [];
  List<Recipe> _allRecipes = [];
  int _currentIndex = 0;

  // Commands
  late final Command0<void> loadData;
  late final Command1<void, Book> addBook;
  late final Command1<void, Book> updateBook;
  late final Command1<void, Book> deleteBook;
  late final Command1<void, Recipe> addRecipe;
  late final Command1<void, Recipe> updateRecipe;
  late final Command1<void, Recipe> deleteRecipe;

  MainNavigationViewModel({
    required BookRepository bookRepository,
    required RecipeRepository recipeRepository,
  })  : _bookRepository = bookRepository,
        _recipeRepository = recipeRepository {
    loadData = Command0<void>(_loadData);
    addBook = Command1<void, Book>(_addBook);
    updateBook = Command1<void, Book>(_updateBook);
    deleteBook = Command1<void, Book>(_deleteBook);
    addRecipe = Command1<void, Recipe>(_addRecipe);
    updateRecipe = Command1<void, Recipe>(_updateRecipe);
    deleteRecipe = Command1<void, Recipe>(_deleteRecipe);
  }

  List<Book> get books => _books;
  List<Recipe> get allRecipes => _allRecipes;
  int get currentIndex => _currentIndex;

  /// Load all data (books and recipes)
  Future<Result<void>> _loadData() async {
    try {
      final books = await _bookRepository.getBooks();
      final recipes = await _recipeRepository.getAllRecipes();
      _books = books;
      _allRecipes = recipes;
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load data: $e'));
    }
  }

  /// Add a new book
  Future<Result<void>> _addBook(Book book) async {
    try {
      await _bookRepository.createBook(book.title, book.author);
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to create book: $e'));
    }
  }

  /// Update an existing book
  Future<Result<void>> _updateBook(Book book) async {
    try {
      await _bookRepository.updateBook(book.id!, book.title, book.author);
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to update book: $e'));
    }
  }

  /// Delete a book
  Future<Result<void>> _deleteBook(Book book) async {
    try {
      await _bookRepository.deleteBook(book.id!);
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete book: $e'));
    }
  }

  /// Add a new recipe
  Future<Result<void>> _addRecipe(Recipe recipe) async {
    try {
      await _recipeRepository.createRecipe(
        recipe.bookId,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to create recipe: $e'));
    }
  }

  /// Update an existing recipe
  Future<Result<void>> _updateRecipe(Recipe recipe) async {
    try {
      await _recipeRepository.updateRecipe(
        recipe.id!,
        recipe.title,
        recipe.page,
        recipe.tags,
      );
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to update recipe: $e'));
    }
  }

  /// Delete a recipe
  Future<Result<void>> _deleteRecipe(Recipe recipe) async {
    try {
      await _recipeRepository.deleteRecipe(recipe.id!);
      await _loadData();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete recipe: $e'));
    }
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

