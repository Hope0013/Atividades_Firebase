import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Constantes gerais do aplicativo The Librarian.
/// Centraliza valores como nomes de coleções no Firestore e chaves de estantes.
class AppConstants {
  // Nomes de Coleções no Firestore
  static const String usersCollection = 'users';
  static const String booksSubcollection = 'books';
  static const String statsSubcollection = 'stats';
  static const String statsSummaryDoc = 'summary';

  // Identificadores das Estantes
  static const String shelfQueroLer = 'quero_ler';
  static const String shelfLendo = 'lendo';
  static const String shelfLido = 'lido';

  // Lista com todas as estantes disponíveis
  static const List<String> allShelves = [
    shelfQueroLer,
    shelfLendo,
    shelfLido,
  ];

  /// Retorna o nome amigável para exibição da estante
  static String getShelfLabel(String shelfKey) {
    switch (shelfKey) {
      case shelfQueroLer:
        return 'Quero Ler';
      case shelfLendo:
        return 'Lendo';
      case shelfLido:
        return 'Lidos';
      default:
        return 'Estante';
    }
  }

  /// Retorna a cor característica de cada estante
  static Color getShelfColor(String shelfKey) {
    switch (shelfKey) {
      case shelfQueroLer:
        return AppColors.shelfQueroLer;
      case shelfLendo:
        return AppColors.shelfLendo;
      case shelfLido:
        return AppColors.shelfLido;
      default:
        return AppColors.sepiaMuted;
    }
  }

  /// Retorna um ícone temático para cada estante
  static IconData getShelfIcon(String shelfKey) {
    switch (shelfKey) {
      case shelfQueroLer:
        return Icons.bookmark_add_outlined;
      case shelfLendo:
        return Icons.menu_book_rounded;
      case shelfLido:
        return Icons.verified_outlined;
      default:
        return Icons.book;
    }
  }
}
