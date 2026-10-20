import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/book_model.dart';
import '../models/user_stats_model.dart';

/// Serviço responsável por todas as operações de banco de dados no Cloud Firestore.
/// Segue a estrutura:
/// - Coleção principal: `users/{userId}/books/{bookId}`
/// - Documento de estatísticas: `users/{userId}/stats/summary`
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna a referência da subcoleção de livros do usuário
  CollectionReference<Map<String, dynamic>> _userBooksRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.booksSubcollection);
  }

  /// Retorna a referência do documento de estatísticas do usuário
  DocumentReference<Map<String, dynamic>> _userStatsRef(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.statsSubcollection)
        .doc(AppConstants.statsSummaryDoc);
  }

  // ===========================================================================
  // OPERAÇÕES DE ESTANTE / LIVROS
  // ===========================================================================

  /// Adiciona um novo livro ou atualiza um livro existente na estante do usuário
  Future<void> saveBookToShelf({
    required String userId,
    required BookModel book,
    required String shelfKey,
  }) async {
    final bookData = book.copyWith(status: shelfKey).toFirestore();

    // Usamos o próprio ID do livro (do Google Books) como ID do documento
    // para evitar livros duplicados na estante.
    await _userBooksRef(userId).doc(book.id).set(bookData, SetOptions(merge: true));
  }

  /// Altera o status (estante) de um livro específico ('quero_ler', 'lendo', 'lido')
  /// Isso irá disparar a Cloud Function 'onBookUpdated' quando o status for 'lido'!
  Future<void> updateBookShelf({
    required String userId,
    required String bookId,
    required String newShelfKey,
  }) async {
    await _userBooksRef(userId).doc(bookId).update({
      'status': newShelfKey,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove um livro da estante do leitor
  Future<void> removeBookFromShelf({
    required String userId,
    required String bookId,
  }) async {
    await _userBooksRef(userId).doc(bookId).delete();
  }

  /// Stream em tempo real dos livros filtrados por estante ('quero_ler', 'lendo' ou 'lido')
  Stream<List<BookModel>> streamBooksByShelf({
    required String userId,
    required String shelfKey,
  }) {
    return _userBooksRef(userId)
        .where('status', isEqualTo: shelfKey)
        .snapshots()
        .map((snapshot) {
          final books = snapshot.docs.map((doc) {
            return BookModel.fromFirestore(doc.data(), doc.id);
          }).toList();

          // Ordenação por data mais recente de atualização no lado do cliente
          books.sort((a, b) {
            final aDate = a.updatedAt ?? a.addedAt ?? DateTime(2000);
            final bDate = b.updatedAt ?? b.addedAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

          return books;
        });
  }

  /// Stream em tempo real de TODOS os livros do usuário (útil para verificar
  /// se um livro pesquisado já está em alguma estante)
  Stream<List<BookModel>> streamAllUserBooks(String userId) {
    return _userBooksRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ===========================================================================
  // ESTATÍSTICAS DO LEITOR (LIVROS E PÁGINAS LIDAS)
  // ===========================================================================

  /// Stream em tempo real do documento `/users/{userId}/stats/summary`.
  /// Este documento é mantido e incrementado pela nossa Cloud Function.
  Stream<UserStatsModel> streamUserStats(String userId) {
    return _userStatsRef(userId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return UserStatsModel.empty();
      }
      return UserStatsModel.fromFirestore(snapshot.data());
    });
  }

  /// Método auxiliar de segurança (Fallback): Se a Cloud Function ainda não tiver sido
  /// implantada no Firebase pelo estudante, podemos recalcular as estatísticas
  /// diretamente a partir dos livros marcados como 'lido' no Firestore.
  Future<UserStatsModel> recalculateStatsManually(String userId) async {
    final query = await _userBooksRef(userId)
        .where('status', isEqualTo: AppConstants.shelfLido)
        .get();

    int totalLivros = query.docs.length;
    int totalPaginas = 0;

    for (var doc in query.docs) {
      final data = doc.data();
      final pages = (data['pageCount'] as num?)?.toInt() ?? 0;
      totalPaginas += pages;
    }

    final summary = {
      'livrosLidos': totalLivros,
      'paginasLidas': totalPaginas,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Salva o resumo no mesmo documento que a Cloud Function usaria
    await _userStatsRef(userId).set(summary, SetOptions(merge: true));

    return UserStatsModel(
      livrosLidos: totalLivros,
      paginasLidas: totalPaginas,
      updatedAt: DateTime.now(),
    );
  }
}
