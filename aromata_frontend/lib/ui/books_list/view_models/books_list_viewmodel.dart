import 'package:aromata_frontend/repositories/book_repository.dart';
import 'package:aromata_frontend/repositories/recipe_repository.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/recipe.dart';
import 'package:aromata_frontend/utils/command.dart';

class BooksListViewModel extends ChangeNotifier {
  final BookRepository _bookRepository;
  final RecipeRepository _recipeRepository;
  late final Command0<void> loadData;

  List<Book> _books = [];
  List<Recipe> _allRecipes = [];

  BooksListViewModel({
    required BookRepository bookRepository,
    required RecipeRepository recipeRepository,
  })  : _bookRepository = bookRepository,
        _recipeRepository = recipeRepository {
    loadData = Command0<void>(_loadBooks);
  }

  List<Book> get books => _books;
  List<Recipe> get allRecipes => _allRecipes;

  Future<Result<void>> _loadBooks() async {
    try {
      _books = await _bookRepository.getBooks();
      _allRecipes = await _recipeRepository.getAllRecipes();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to load books: $e'));
    }
    finally {
      notifyListeners();
    }
  }
}

