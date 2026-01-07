import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/book_repository.dart';
import '../../../repositories/recipe_repository.dart';
import '../../../viewmodels/base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final BookRepository _bookRepository;
  final RecipeRepository _recipeRepository;

  int _bookCount = 0;
  int _recipeCount = 0;

  late final Command0<void> signOut;
  late final Command0<void> loadCounts;

  ProfileViewModel({
    required AuthRepository authRepository,
    required BookRepository bookRepository,
    required RecipeRepository recipeRepository,
  })  : _authRepository = authRepository,
        _bookRepository = bookRepository,
        _recipeRepository = recipeRepository {
    signOut = Command0<void>(_signOut);
    loadCounts = Command0<void>(_loadCounts);
  }

  int get bookCount => _bookCount;
  int get recipeCount => _recipeCount;

  Future<Result<void>> _loadCounts() async {
    try {
      final books = await _bookRepository.getBooks();
      final recipes = await _recipeRepository.getAllRecipes();
      _bookCount = books.length;
      _recipeCount = recipes.length;
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load counts: $e'));
    }
  }

  String getUserName() {    
    return _authRepository.getCurrentUserName() ?? 'User';
  }

  String getUserEmail() {
    return _authRepository.getCurrentUserEmail() ?? 'user@example.com';
  }

  Future<Result<void>> _signOut() async {
    final result = await _authRepository.signOut();
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }
}

