import '../domain/models/recipe.dart';
import 'base_viewmodel.dart';

class CreateRecipeViewModel extends BaseViewModel {
  final String bookId;
  final Recipe? initialRecipe;

  String _title = '';
  String _page = '';
  List<String> _tags = [];
  String _tagInput = '';

  CreateRecipeViewModel({
    required this.bookId,
    this.initialRecipe,
  }) {
    if (initialRecipe != null) {
      _title = initialRecipe!.title;
      _page = initialRecipe!.page.toString();
      _tags = List<String>.from(initialRecipe!.tags);
    }
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

  Recipe? createRecipe() {
    if (!isValid) return null;

    final pageNum = int.tryParse(_page.trim());
    if (pageNum == null || pageNum < 1) return null;

    return Recipe(
      id: initialRecipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      title: _title.trim(),
      page: pageNum,
      tags: _tags,
    );
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

