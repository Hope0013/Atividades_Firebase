import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/book_model.dart';

/// Serviço responsável pela busca de livros e consumo de APIs bibliográficas externas.
/// Utiliza a Open Library API (https://openlibrary.org/developers/api) como fonte principal
/// de dados do catálogo de livros, garantindo alta disponibilidade, gratuidade
/// e sem bloqueios por limites de cota (429).
class GoogleBooksService {
  static const String _googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// Realiza a busca de livros no acervo literário.
  /// Consulta prioritariamente a Open Library API (https://openlibrary.org/developers/api).
  /// Caso a busca na Open Library não retorne resultados, tenta de forma resiliente
  /// a Google Books API como mecanismo secundário de fallback.
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 25}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    try {
      // 1. Busca prioritária via Open Library API pública
      final openLibraryResults = await _searchOpenLibrary(cleanQuery, maxResults: maxResults);
      if (openLibraryResults.isNotEmpty) {
        return openLibraryResults;
      }

      // Se a Open Library não tiver retornado nenhum registro, tenta o fallback
      if (kDebugMode) {
        print('[TheLibrarian] Open Library sem resultados para "$cleanQuery". Testando fallback...');
      }
      return await _searchGoogleBooksSafe(cleanQuery, maxResults: maxResults);
    } catch (e) {
      if (kDebugMode) {
        print('[TheLibrarian] Erro na consulta primária Open Library: $e. Tentando fallback...');
      }
      final fallbackResults = await _searchGoogleBooksSafe(cleanQuery, maxResults: maxResults);
      if (fallbackResults.isNotEmpty) {
        return fallbackResults;
      }
      if (e is String) rethrow;
      throw 'Não foi possível carregar os livros no momento. Verifique sua conexão e tente novamente.';
    }
  }

  /// Consulta primária via Open Library API pública (https://openlibrary.org/developers/api)
  Future<List<BookModel>> _searchOpenLibrary(String cleanQuery, {int maxResults = 25}) async {
    try {
      final uri = Uri.https('openlibrary.org', '/search.json', {
        'q': cleanQuery,
        'limit': '$maxResults',
        'fields': 'key,title,author_name,cover_i,cover_edition_key,isbn,number_of_pages_median,number_of_pages,first_sentence,subtitle,subject,first_publish_year',
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'User-Agent': 'TheLibrarian/1.0 (academic_project; https://github.com)',
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Tempo limite esgotado. Verifique sua conexão com a internet.';
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody) as Map<String, dynamic>;
        final docs = data['docs'] as List<dynamic>?;

        if (docs == null || docs.isEmpty) {
          return [];
        }

        return docs.map((doc) {
          return BookModel.fromOpenLibrary(doc as Map<String, dynamic>);
        }).toList();
      } else {
        throw 'Erro ao consultar Open Library (Código ${response.statusCode})';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TheLibrarian] Falha no serviço Open Library: $e');
      }
      rethrow;
    }
  }

  /// Consulta secundária (Fallback) com captura segura de falhas
  Future<List<BookModel>> _searchGoogleBooksSafe(String cleanQuery, {int maxResults = 25}) async {
    try {
      String url = '$_googleBooksBaseUrl?q=${Uri.encodeComponent(cleanQuery)}&maxResults=$maxResults&printType=books';
      if (AppConstants.googleBooksApiKey != null && AppConstants.googleBooksApiKey!.isNotEmpty) {
        url += '&key=${AppConstants.googleBooksApiKey}';
      }

      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw 'Tempo limite no Google Books esgotado.',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return [];
        }

        return items.map((item) {
          return BookModel.fromGoogleBooks(item as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[TheLibrarian] Google Books fallback indisponível: $e');
      }
      return [];
    }
  }
}

/// Alias para manter consistência semântica com a migração para Open Library
typedef OpenLibraryService = GoogleBooksService;
