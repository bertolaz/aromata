import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/repositories/recipe_repository.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/recipe.dart';
import '../../../viewmodels/base_viewmodel.dart';

class BookDetailViewModel extends BaseViewModel {
  final BookRepository _bookRepository;
  final RecipeRepository _recipeRepository;
  Book? _book;
  List<Recipe> _recipes = [];

  Book? get book => _book;
  List<Recipe> get recipes => _recipes;
  
  List<Recipe> get sortedRecipes {
    final sorted = List<Recipe>.from(_recipes);
    sorted.sort((a, b) => a.page.compareTo(b.page));
    return sorted;
  }
  
  int get recipeCount => _recipes.length;

  late final Command1<void, String> loadData;
  late final Command1<void, Book> deleteBook;
  
  BookDetailViewModel({
    required BookRepository bookRepository,
    required RecipeRepository recipeRepository,
  })  : _bookRepository = bookRepository,
        _recipeRepository = recipeRepository {
    loadData = Command1<void, String>(_loadData);
    deleteBook = Command1<void, Book>(_deleteBook);
  }

  Future<Result<void>> _loadData(String bookId) async {
    try {
      final book = await _bookRepository.getBookById(bookId);
      if (book == null) {
        return Result.error(Exception('Book not found'));
      }
      _book = book;
      
      final recipes = await _recipeRepository.getRecipesByBookId(book.id!);
      _recipes = recipes;
      
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load data: $e'));
    }
  }

  Future<Result<void>> _deleteBook(Book book) async {
    try {
      await _bookRepository.deleteBook(book.id!);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete book: $e'));
    }
  }

  /// Refresh recipes for the current book
  Future<void> refreshRecipes() async {
    if (_book?.id != null) {
      try {
        final recipes = await _recipeRepository.getRecipesByBookId(_book!.id!);
        _recipes = recipes;
        notifyListeners();
      } catch (e) {
        // Silently fail - could show error if needed
      }
    }
  }
}

