import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../domain/models/recipe.dart';
import '../../../viewmodels/base_viewmodel.dart';
import '../../../repositories/recipe_repository.dart';

class CreateRecipeViewModel extends BaseViewModel {
  final RecipeRepository _recipeRepository;

  String _title = '';
  String _page = '';
  List<String> _tags = [];
  String _tagInput = '';
  String? _initialRecipeId;
  String? get initialRecipeId => _initialRecipeId;
  String? _bookId;

  late final Command0<Recipe?> saveRecipe;
  late final Command0<void> deleteRecipe;
  late final Command0<void> loadInitialRecipe;

  CreateRecipeViewModel({
    required RecipeRepository recipeRepository,
    String? bookId,
    String? initialRecipeId,
  }) : _recipeRepository = recipeRepository {
    saveRecipe = Command0<Recipe?>(_saveRecipe);
    deleteRecipe = Command0<void>(_deleteRecipe);
    _bookId = bookId;
    _initialRecipeId = initialRecipeId;
    loadInitialRecipe = Command0<void>(_loadInitialRecipe);
  }

  Future<Result<void>> _loadInitialRecipe() async {
    try {
      if (_initialRecipeId == null) {
        return Result.ok(null);
      }
      final recipe = await _recipeRepository.getRecipeById(_initialRecipeId!);
      _setInitialRecipe(recipe);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load initial recipe: $e'));
    } finally {
      notifyListeners();
    }
  }

  void _setInitialRecipe(Recipe? recipe) {
    _title = recipe?.title ?? '';
    _page = recipe?.page.toString() ?? '';
    _tags = List<String>.from(recipe?.tags ?? []);
  }

  String get title => _title;
  String get page => _page;
  List<String> get tags => _tags;
  String get tagInput => _tagInput;

  bool get isValid {
    final pageNum = int.tryParse(_page.trim());
    return _title.trim().isNotEmpty && pageNum != null && pageNum > 0;
  }

  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  void setPage(String value) {
    if (_page != value) {
      _page = value;
      notifyListeners();
    }
  }

  void setTagInput(String value) {
    if (_tagInput != value) {
      _tagInput = value;
      notifyListeners();
    }
  }

  void addTag() {
    final tag = _tagInput.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      _tags.add(tag);
      _tagInput = '';
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    if (_tags.remove(tag)) {
      notifyListeners();
    }
  }

  Future<Result<Recipe?>> _saveRecipe() async {
    if (!isValid) {
      return Result.error(
        Exception('Please enter a valid title and page number'),
      );
    }

    final pageNum = int.tryParse(_page.trim());
    if (pageNum == null || pageNum < 1) {
      return Result.error(Exception('Page number must be a positive integer'));
    }

    final recipe = Recipe(
      id: _initialRecipeId,
      bookId: _bookId!,
      title: _title.trim(),
      page: pageNum,
      tags: _tags,
    );

    try {
      if (_initialRecipeId == null) {
        // Create new recipe
        final createdRecipe = await _recipeRepository.createRecipe(
          recipe.bookId,
          recipe.title,
          recipe.page,
          recipe.tags,
        );
        return Result.ok(createdRecipe);
      } else {
        // Update existing recipe
        await _recipeRepository.updateRecipe(
          recipe.id!,
          recipe.title,
          recipe.page,
          recipe.tags,
        );
        return Result.ok(recipe);
      }
    } catch (e) {
      return Result.error(Exception('Failed to save recipe: $e'));
    }
  }

  Future<Result<void>> _deleteRecipe() async {
    if (_initialRecipeId == null) {
      return Result.error(
        Exception('Cannot delete a recipe that has not been saved'),
      );
    }

    try {
      await _recipeRepository.deleteRecipe(_initialRecipeId!);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to delete recipe: $e'));
    }
  }

  void reset() {
    _title = '';
    _page = '';
    _tags = [];
    _tagInput = '';
    clearError();
    notifyListeners();
  }
}
