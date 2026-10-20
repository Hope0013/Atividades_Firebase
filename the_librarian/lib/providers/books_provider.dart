import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
import '../services/google_books_service.dart';

/// Gerenciador de estado para busca de livros e operações de estantes.
/// Centraliza a lógica de negócios da busca na Google Books API
/// e da persistência das estantes no Firestore.
class BooksProvider with ChangeNotifier {
  final GoogleBooksService _booksService = GoogleBooksService();
  final FirestoreService _firestoreService = FirestoreService();

  // Estado da Busca na Google Books API
  List<BookModel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  String _lastQuery = '';

  // Mapa rápido de livros que o usuário já possui em suas estantes
  // Estrutura: { bookId: status ('quero_ler' | 'lendo' | 'lido') }
  final Map<String, String> _userBooksShelves = {};

  // Getters para a UI
  List<BookModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  String get lastQuery => _lastQuery;

  /// Atualiza o mapa interno com os livros do usuário sincronizados com o Firestore
  void syncUserBooks(List<BookModel> books) {
    _userBooksShelves.clear();
    for (var book in books) {
      if (book.status != null) {
        _userBooksShelves[book.id] = book.status!;
      }
    }
    notifyListeners();
  }

  /// Retorna em qual estante o livro está cadastrado (ou null se ainda não estiver)
  String? getBookShelf(String bookId) {
    return _userBooksShelves[bookId];
  }

  /// Executa a busca de livros na Google Books API
  Future<void> searchBooks(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      _searchResults = [];
      _searchError = null;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    _lastQuery = clean;
    notifyListeners();

    try {
      final results = await _booksService.searchBooks(clean);
      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _searchError = e.toString();
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Limpa os resultados da pesquisa
  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    _lastQuery = '';
    notifyListeners();
  }

  /// Adiciona ou altera um livro na estante do usuário no Firestore
  Future<void> saveBookToShelf({
    required String userId,
    required BookModel book,
    required String shelfKey,
  }) async {
    await _firestoreService.saveBookToShelf(
      userId: userId,
      book: book,
      shelfKey: shelfKey,
    );
    _userBooksShelves[book.id] = shelfKey;
    notifyListeners();
  }

  /// Altera apenas o status de um livro já existente
  Future<void> updateBookShelf({
    required String userId,
    required String bookId,
    required String newShelfKey,
  }) async {
    await _firestoreService.updateBookShelf(
      userId: userId,
      bookId: bookId,
      newShelfKey: newShelfKey,
    );
    _userBooksShelves[bookId] = newShelfKey;
    notifyListeners();
  }

  /// Remove um livro da estante do usuário
  Future<void> removeBook({
    required String userId,
    required String bookId,
  }) async {
    await _firestoreService.removeBookFromShelf(
      userId: userId,
      bookId: bookId,
    );
    _userBooksShelves.remove(bookId);
    notifyListeners();
  }
}
