import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/book_model.dart';

/// Serviço responsável pela integração com catálogos literários públicos.
/// Implementa arquitetura resiliente com suporte ao Google Books API
/// e fallback automático transparente para a Open Library API quando
/// ocorrer erro 429 (Too Many Requests / Quota Excedida) ou 403 (Acesso bloqueado).
class GoogleBooksService {
  static const String _googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _openLibraryBaseUrl = 'https://openlibrary.org/search.json';

  // Controle de cooldown em memória: se o Google Books retornar 429/403,
  // evita chamadas repetidas que sabidamente falharão, respondendo instantaneamente via Open Library.
  static bool _isGoogleThrottled = false;
  static DateTime? _throttledUntil;

  /// Realiza a busca de livros de forma resiliente.
  /// Tenta o Google Books. Caso o Google Books retorne 429 (Rate Limit) ou falhe,
  /// ativa automaticamente o acervo Open Library, garantindo que a busca NUNCA quebre.
  Future<List<BookModel>> searchBooks(String query, {int maxResults = 25}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    // Se o Google Books estiver em cooldown por erro 429, consulta Open Library direto
    if (_isGoogleThrottled && _throttledUntil != null) {
      if (DateTime.now().isBefore(_throttledUntil!)) {
        if (kDebugMode) {
          print('[TheLibrarian] Google Books em cooldown (429/403). Buscando na Open Library...');
        }
        return await _searchOpenLibrary(cleanQuery, maxResults: maxResults);
      } else {
        _isGoogleThrottled = false;
        _throttledUntil = null;
      }
    }

    try {
      final googleResults = await _searchGoogleBooks(cleanQuery, maxResults: maxResults);
      if (googleResults.isNotEmpty) {
        return googleResults;
      }
      // Se não encontrou no Google Books, tenta ainda na Open Library
      return await _searchOpenLibrary(cleanQuery, maxResults: maxResults);
    } catch (e) {
      if (kDebugMode) {
        print('[TheLibrarian] Google Books indisponível ($e). Ativando fallback Open Library...');
      }
      return await _searchOpenLibrary(cleanQuery, maxResults: maxResults);
    }
  }

  /// Consulta primária via Google Books API
  Future<List<BookModel>> _searchGoogleBooks(String cleanQuery, {int maxResults = 25}) async {
    String url = '$_googleBooksBaseUrl?q=${Uri.encodeComponent(cleanQuery)}&maxResults=$maxResults&printType=books';
    if (AppConstants.googleBooksApiKey != null && AppConstants.googleBooksApiKey!.isNotEmpty) {
      url += '&key=${AppConstants.googleBooksApiKey}';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri).timeout(
      const Duration(seconds: 6),
      onTimeout: () => throw 'Tempo limite no Google Books esgotado.',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;

      if (items == null || items.isEmpty) {
        return [];
      }

      return items.map((item) {
        return BookModel.fromGoogleBooks(item as Map<String, dynamic>);
      }).toList();
    } else if (response.statusCode == 429 || response.statusCode == 403) {
      // 429 (Too Many Requests / Quota Exceeded) ou 403 (Blocked API)
      _isGoogleThrottled = true;
      _throttledUntil = DateTime.now().add(const Duration(minutes: 20));
      throw 'Google Books Rate Limit (Código ${response.statusCode})';
    } else {
      throw 'Erro ao consultar Google Books (Código ${response.statusCode})';
    }
  }

  /// Consulta secundária (Fallback) via Open Library API pública
  Future<List<BookModel>> _searchOpenLibrary(String cleanQuery, {int maxResults = 25}) async {
    try {
      final uri = Uri.parse(
        '$_openLibraryBaseUrl?q=${Uri.encodeComponent(cleanQuery)}&limit=$maxResults&fields=key,title,author_name,cover_i,cover_edition_key,isbn,number_of_pages_median,number_of_pages,first_sentence,subtitle,subject,first_publish_year',
      );

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
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['docs'] as List<dynamic>?;

        if (docs == null || docs.isEmpty) {
          return [];
        }

        return docs.map((doc) {
          return BookModel.fromOpenLibrary(doc as Map<String, dynamic>);
        }).toList();
      } else {
        throw 'Erro ao consultar acervo (Código ${response.statusCode})';
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TheLibrarian] Erro na Open Library: $e');
      }
      if (e is String) rethrow;
      throw 'Não foi possível carregar os livros no momento. Verifique sua conexão e tente novamente.';
    }
  }
}
