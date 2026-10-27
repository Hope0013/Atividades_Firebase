import 'package:flutter_test/flutter_test.dart';
import 'package:the_librarian/services/google_books_service.dart';

void main() {
  test('Busca de livros deve retornar obras com sucesso mesmo com 429 no Google Books', () async {
    final service = GoogleBooksService();
    final books = await service.searchBooks('Machado de Assis', maxResults: 5);

    expect(books, isNotEmpty);

    final firstBook = books.first;
    expect(firstBook.title, isNotEmpty);
    expect(firstBook.id, isNotEmpty);
  });
}
