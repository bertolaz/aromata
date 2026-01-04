import '../domain/models/book.dart';
import 'base_viewmodel.dart';

class CreateBookViewModel extends BaseViewModel {
  String _title = '';
  String _author = '';

  String get title => _title;
  String get author => _author;

  bool get isValid => _title.trim().isNotEmpty && _author.trim().isNotEmpty;

  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  void setAuthor(String value) {
    if (_author != value) {
      _author = value;
      notifyListeners();
    }
  }

  Book? createBook() {
    if (!isValid) return null;

    return Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.trim(),
      author: _author.trim(),
    );
  }

  void reset() {
    _title = '';
    _author = '';
    clearError();
    notifyListeners();
  }
}

