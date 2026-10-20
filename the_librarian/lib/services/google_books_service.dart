import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

/// Serviço responsável pela integração com a Google Books API pública.
/// Permite pesquisar obras por título, autor ou palavras-chave.
class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Realiza a busca de livros na Google Books API.
  /// Aceita [query] (texto digitado pelo usuário) e [maxResults] (limite de itens).
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 25}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    try {
      // Monta a URL codificando caracteres especiais (espaços, acentos, etc.)
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(cleanQuery)}&maxResults=$maxResults&printType=books',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw 'Tempo limite esgotado. Verifique sua conexão com a internet.';
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return [];
        }

        // Converte cada item do JSON no nosso modelo BookModel
        final books = items.map((item) {
          return BookModel.fromGoogleBooks(item as Map<String, dynamic>);
        }).toList();

        return books;
      } else {
        throw 'Erro ao consultar Google Books (Código ${response.statusCode})';
      }
    } catch (e) {
      // Propaga o erro de forma clara para a camada de visualização (UI)
      if (e is String) rethrow;
      throw 'Não foi possível buscar os livros no momento. Tente novamente.';
    }
  }
}
