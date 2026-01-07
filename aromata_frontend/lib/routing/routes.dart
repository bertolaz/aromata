abstract final class Routes {
  static const String login = '/login';
  static const String books = '/$booksRelative';
  static const String booksRelative = 'books';
  static  String bookWithId(String bookId) => '$books/$bookId';
  static const String createBook = '$books/create';
  static const String search = '/$searchRelative';
  static const String searchRelative = 'search';
  static const String recipes = '/$recipesRelative';
  static const String recipesRelative = 'recipes';
  static  String recipeWithId(String recipeId) => '$recipes/$recipeId';
  static  String createRecipe(String bookId) => '$recipes/create?bookId=$bookId';
  static  String bulkImport(String bookId) => '$recipes/bulk-import?bookId=$bookId';
  static const String profile = '/profile';
  static const String privacy = '/privacy';
}