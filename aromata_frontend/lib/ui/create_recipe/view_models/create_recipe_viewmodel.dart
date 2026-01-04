import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../domain/models/recipe.dart';
import '../../../viewmodels/base_viewmodel.dart';
import '../../../repositories/recipe_repository.dart';

class CreateRecipeViewModel extends BaseViewModel {
  final String bookId;
  final Recipe? initialRecipe;
  final RecipeRepository _recipeRepository;

  String _title = '';
  String _page = '';
  List<String> _tags = [];
  String _tagInput = '';

  late final Command0<Recipe?> saveRecipe;
  late final Command0<void> deleteRecipe;

  CreateRecipeViewModel({
    required this.bookId,
    this.initialRecipe,
    required RecipeRepository recipeRepository,
  }) : _recipeRepository = recipeRepository {
    if (initialRecipe != null) {
      _title = initialRecipe!.title;
      _page = initialRecipe!.page.toString();
      _tags = List<String>.from(initialRecipe!.tags);
    }
    saveRecipe = Command0<Recipe?>(_saveRecipe);
    deleteRecipe = Command0<void>(_deleteRecipe);
  }

  void setInitialRecipe(Recipe recipe) {
    _title = recipe.title;
    _page = recipe.page.toString();
    _tags = List<String>.from(recipe.tags);
    notifyListeners();
  }

  String get title => _title;
  String get page => _page;
  List<String> get tags => _tags;
  String get tagInput => _tagInput;

  bool get isValid {
    final pageNum = int.tryParse(_page.trim());
    return _title.trim().isNotEmpty && 
           pageNum != null && 
           pageNum > 0;
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
      return Result.error(Exception('Please enter a valid title and page number'));
    }

    final pageNum = int.tryParse(_page.trim());
    if (pageNum == null || pageNum < 1) {
      return Result.error(Exception('Page number must be a positive integer'));
    }

    final recipe = Recipe(
      id: initialRecipe?.id,
      bookId: bookId,
      title: _title.trim(),
      page: pageNum,
      tags: _tags,
    );

    try {
      if (initialRecipe == null) {
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
    if (initialRecipe == null || initialRecipe!.id == null) {
      return Result.error(Exception('Cannot delete a recipe that has not been saved'));
    }

    try {
      await _recipeRepository.deleteRecipe(initialRecipe!.id!);
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

