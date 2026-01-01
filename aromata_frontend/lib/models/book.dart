class Book {
  final String? id;
  final String title;
  final String author;

  Book({
    this.id,
    required this.title,
    required this.author,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
    );
  }
}

