import '../../../domain/models/book.dart';
import '../../../viewmodels/base_viewmodel.dart';
import '../../../repositories/book_repository.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';

class CreateBookViewModel extends BaseViewModel {
  final BookRepository _bookRepository;

  String _title = '';
  String _author = '';

  late final Command0<Book?> createBook;

  CreateBookViewModel({required BookRepository bookRepository}) 
      : _bookRepository = bookRepository {
    createBook = Command0<Book?>(_createBook);
  }

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

  Future<Result<Book?>> _createBook() async {
    if (!isValid) {
      return Result.error(Exception('Title and author are required'));
    }

    try {
      final createdBook = await _bookRepository.createBook(
        _title.trim(),
        _author.trim(),
      );
      return Result.ok(createdBook);
    } catch (e) {
      return Result.error(Exception('Failed to create book: $e'));
    }
  }

  void reset() {
    _title = '';
    _author = '';
    clearError();
    notifyListeners();
  }
}

