import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo de estatísticas de leitura do usuário.
/// Armazenado em `/users/{userId}/stats/summary` e atualizado pela Cloud Function.
class UserStatsModel {
  final int livrosLidos;
  final int paginasLidas;
  final DateTime? updatedAt;

  UserStatsModel({
    required this.livrosLidos,
    required this.paginasLidas,
    this.updatedAt,
  });

  /// Instância inicial vazia para quando o usuário ainda não tiver lido nenhum livro
  factory UserStatsModel.empty() {
    return UserStatsModel(
      livrosLidos: 0,
      paginasLidas: 0,
      updatedAt: null,
    );
  }

  /// Constrói o modelo a partir do documento Firestore `/users/{userId}/stats/summary`
  factory UserStatsModel.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return UserStatsModel.empty();

    DateTime? updatedAt;
    if (data['updatedAt'] is Timestamp) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    }

    return UserStatsModel(
      livrosLidos: (data['livrosLidos'] as num?)?.toInt() ?? 0,
      paginasLidas: (data['paginasLidas'] as num?)?.toInt() ?? 0,
      updatedAt: updatedAt,
    );
  }

  /// Retorna um título honorário vintage baseado no número de livros lidos
  String get readerTitle {
    if (livrosLidos == 0) return 'Iniciante da Biblioteca';
    if (livrosLidos < 3) return 'Leitor Curioso';
    if (livrosLidos < 7) return 'Bibliófilo Dedicado';
    if (livrosLidos < 15) return 'Devorador de Tomos';
    if (livrosLidos < 30) return 'Arquivista Imperial';
    return 'Grão-Mestre da Biblioteca';
  }

  /// Descrição poética do nível do leitor
  String get readerDescription {
    if (livrosLidos == 0) {
      return 'Abra as portas do conhecimento escolhendo seu primeiro volume.';
    }
    if (livrosLidos < 3) {
      return 'Você deu os primeiros passos em sua jornada literária.';
    }
    if (livrosLidos < 7) {
      return 'Sua estante ganha vida com histórias e sabedoria acumulada.';
    }
    if (livrosLidos < 15) {
      return 'Um leitor voraz cujo apetite por novas páginas nunca cessa!';
    }
    return 'Poucos alcançam este patamar de erudição e paixão pela leitura.';
  }

  /// Ícone representativo da patente do leitor
  IconData get readerIcon {
    if (livrosLidos == 0) return Icons.local_florist_outlined;
    if (livrosLidos < 3) return Icons.bookmark_added_outlined;
    if (livrosLidos < 7) return Icons.auto_stories;
    if (livrosLidos < 15) return Icons.military_tech_outlined;
    return Icons.workspace_premium;
  }
}
