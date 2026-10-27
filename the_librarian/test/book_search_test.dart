import 'package:flutter_test/flutter_test.dart';
import 'package:the_librarian/services/google_books_service.dart';

void main() {
  test('Busca de livros deve retornar obras com sucesso via Open Library API', () async {
    final service = GoogleBooksService();
    final books = await service.searchBooks('Machado de Assis', maxResults: 5);

    expect(books, isNotEmpty);

    final firstBook = books.first;
    expect(firstBook.title, isNotEmpty);
    expect(firstBook.id, isNotEmpty);
    expect(firstBook.authors, isNotEmpty);
  });

  test('Alias OpenLibraryService deve funcionar identicamente', () async {
    final service = OpenLibraryService();
    final books = await service.searchBooks('Dom Casmurro', maxResults: 3);

    expect(books, isNotEmpty);
    expect(books.first.title.toLowerCase(), contains('dom casmurro'));
  });
}

