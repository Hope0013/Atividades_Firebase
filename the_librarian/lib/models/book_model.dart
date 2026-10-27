import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de dados que representa um Livro.
/// Esta classe é responsável por converter dados vindos tanto da
/// Google Books API (JSON) quanto do banco de dados Cloud Firestore (Map).
class BookModel {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnail;
  final int pageCount;
  final String? status; // 'quero_ler', 'lendo', 'lido'
  final DateTime? addedAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnail,
    required this.pageCount,
    this.status,
    this.addedAt,
    this.updatedAt,
  });

  /// Texto formatado dos autores (ex: "J.K. Rowling, John Tiffany")
  String get authorsText {
    if (authors.isEmpty) return 'Autor desconhecido';
    return authors.join(', ');
  }

  /// Retorna se há uma imagem de capa válida
  bool get hasThumbnail => thumbnail.isNotEmpty;

  /// Retorna o número de páginas formatado
  String get pageCountFormatted {
    if (pageCount <= 0) return 'Páginas n/d';
    return '$pageCount págs.';
  }

  /// Constrói um objeto [BookModel] a partir da resposta da Google Books API
  factory BookModel.fromGoogleBooks(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    final title = volumeInfo['title'] as String? ?? 'Sem título';
    
    // Tratamento seguro para lista de autores
    final authorsList = <String>[];
    if (volumeInfo['authors'] != null && volumeInfo['authors'] is List) {
      for (var author in volumeInfo['authors']) {
        if (author is String) authorsList.add(author);
      }
    }

    final description = volumeInfo['description'] as String? ?? 'Sem descrição disponível.';

    // Google Books pode retornar links com http: -> convertemos para https:
    String thumbnail = '';
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    if (imageLinks != null) {
      final rawImage = imageLinks['thumbnail'] as String? ?? imageLinks['smallThumbnail'] as String? ?? '';
      thumbnail = rawImage.replaceFirst('http://', 'https://');
    }

    // Google Books pageCount
    final pageCount = (volumeInfo['pageCount'] as num?)?.toInt() ?? 0;

    return BookModel(
      id: id,
      title: title,
      authors: authorsList,
      description: description,
      thumbnail: thumbnail,
      pageCount: pageCount,
    );
  }

  /// Constrói um objeto [BookModel] a partir da Open Library API (Catálogo Aberto / Fallback resiliente)
  factory BookModel.fromOpenLibrary(Map<String, dynamic> doc) {
    // Normaliza a chave para ser um ID válido e seguro no Firestore (sem barras '/')
    final rawKey = (doc['key'] as String? ?? '')
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'^_+'), '');
    final id = rawKey.isNotEmpty
        ? 'ol_$rawKey'
        : (doc['cover_edition_key'] as String? ?? 'ol_${DateTime.now().millisecondsSinceEpoch}');

    final title = doc['title'] as String? ?? 'Sem título';

    // Lista de autores
    final authorsList = <String>[];
    if (doc['author_name'] != null && doc['author_name'] is List) {
      for (var author in doc['author_name']) {
        if (author is String) {
          authorsList.add(author);
        }
      }
    }

    // Descrição / Sinopse com múltiplos fallbacks inteligentes
    String description = '';
    if (doc['first_sentence'] != null) {
      if (doc['first_sentence'] is List && (doc['first_sentence'] as List).isNotEmpty) {
        description = (doc['first_sentence'] as List).first.toString();
      } else if (doc['first_sentence'] is String) {
        description = doc['first_sentence'] as String;
      }
    }
    if (description.isEmpty && doc['subtitle'] != null) {
      description = doc['subtitle'].toString();
    }
    if (description.isEmpty && doc['subject'] != null && doc['subject'] is List) {
      final subjects = (doc['subject'] as List).take(3).map((s) => s.toString()).join(', ');
      if (subjects.isNotEmpty) {
        description = 'Gêneros literários: $subjects.';
      }
    }
    if (description.isEmpty) {
      if (doc['first_publish_year'] != null) {
        description = 'Obra clássica catalogada. Ano original: ${doc['first_publish_year']}.';
      } else {
        description = 'Obra catalogada via acervo bibliográfico.';
      }
    }

    // Capa do livro (Open Library Covers API)
    String thumbnail = '';
    if (doc['cover_i'] != null) {
      thumbnail = 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg';
    } else if (doc['cover_edition_key'] != null) {
      thumbnail = 'https://covers.openlibrary.org/b/olid/${doc['cover_edition_key']}-M.jpg';
    } else if (doc['isbn'] != null && doc['isbn'] is List && (doc['isbn'] as List).isNotEmpty) {
      thumbnail = 'https://covers.openlibrary.org/b/isbn/${(doc['isbn'] as List).first}-M.jpg';
    }

    // Contagem de páginas
    int pageCount = 0;
    if (doc['number_of_pages_median'] != null) {
      pageCount = (doc['number_of_pages_median'] as num).toInt();
    } else if (doc['number_of_pages'] != null) {
      pageCount = (doc['number_of_pages'] as num).toInt();
    } else if (doc['number_of_pages'] != null) {
      pageCount = (doc['number_of_pages'] as num).toInt();
    }

    return BookModel(
      id: id,
      title: title,
      authors: authorsList,
      description: description,
      thumbnail: thumbnail,
      pageCount: pageCount,
    );
  }

  /// Constrói um objeto [BookModel] a partir de um documento do Firestore
  factory BookModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    // Tratamento seguro para autores
    final authorsList = <String>[];
    if (data['authors'] != null && data['authors'] is List) {
      for (var author in data['authors']) {
        if (author is String) authorsList.add(author);
      }
    }

    // Tratamento de datas do Firestore (Timestamp)
    DateTime? addedAt;
    if (data['addedAt'] is Timestamp) {
      addedAt = (data['addedAt'] as Timestamp).toDate();
    }

    DateTime? updatedAt;
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    }

    return BookModel(
      id: documentId,
      title: data['title'] as String? ?? 'Sem título',
      authors: authorsList,
      description: data['description'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
      pageCount: (data['pageCount'] as num?)?.toInt() ?? 0,
      status: data['status'] as String?,
      addedAt: addedAt,
      updatedAt: updatedAt,
    );
  }

  /// Converte o modelo para o formato que será salvo no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authors': authors,
      'description': description,
      'thumbnail': thumbnail,
      'pageCount': pageCount,
      'status': status,
      'addedAt': addedAt != null ? Timestamp.fromDate(addedAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Permite criar uma cópia do livro com dados alterados (útil ao mudar de estante)
  BookModel copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? description,
    String? thumbnail,
    int? pageCount,
    String? status,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      pageCount: pageCount ?? this.pageCount,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
