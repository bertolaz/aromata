abstract final class Routes {
  static const String login = '/login';
  static const String home = '/';
  static const String books = '/$booksRelative';
  static const String booksRelative = 'books';
  static  String bookWithId(String bookId) => '/$booksRelative/$bookId';
  static const String search = '/$searchRelative';
  static const String searchRelative = 'search';
  static const String recipes = '/$recipesRelative';
  static const String recipesRelative = 'recipes';
  static  String recipeWithId(String recipeId) => '/$recipesRelative/$recipeId';
  static const String createBook = '/$booksRelative/create';
  static const String profile = '/profile';
  static const String privacy = '/privacy';
}