import 'package:aromata_frontend/domain/models/book.dart';
import 'package:aromata_frontend/domain/models/recipe.dart';
import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/material.dart';
import '../../../repositories/recipe_repository.dart';

class SearchRecipeDetailViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;
  final BookRepository _bookRepository;
  Recipe? _recipe;

  Recipe? get recipe => _recipe;

  Book? _book;
  Book? get book => _book;

  late final Command1<void, String> loadData;

  SearchRecipeDetailViewModel({
    required RecipeRepository recipeRepository,
    required BookRepository bookRepository,
  })  : _recipeRepository = recipeRepository,
        _bookRepository = bookRepository {
    loadData = Command1<void, String>(_loadData);
    // Forward Command state changes to ViewModel listeners
    loadData.addListener(notifyListeners);
  }

  @override
  void dispose() {
    loadData.removeListener(notifyListeners);
    super.dispose();
  }

  Future<Result<void>> _loadData(String recipeId) async {
    try {
      final recipe = await _recipeRepository.getRecipeById(recipeId);
      if (recipe == null) {
        return Result.error(Exception('Recipe not found'));
      }
      _recipe = recipe;
      final book = await _bookRepository.getBookById(recipe.bookId);
      if (book == null) {
        return Result.error(Exception('Book not found'));
      }
      _book = book;
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load data: $e'));
    }
  }
}