import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_stats_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

/// Tela do Painel de Estatísticas de Leitura ("Minhas Estatísticas").
/// Lê em tempo real do Cloud Firestore em `/users/{userId}/stats/summary`,
/// alimentado automaticamente pela Cloud Function `onBookUpdated`.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isRecalculating = false;

  void _handleManualSync(String userId) async {
    setState(() => _isRecalculating = true);
    try {
      final stats = await _firestoreService.recalculateStatsManually(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.forestGreen,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Estatísticas recalculadas: ${stats.livrosLidos} livros e ${stats.paginasLidas} páginas!',
              style: GoogleFonts.lora(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text('Erro ao recalcular estatísticas: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecalculating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Conecte-se para ver suas estatísticas.'));
    }

    return Scaffold(
      backgroundColor: AppColors.parchmentLight,
      body: StreamBuilder<UserStatsModel>(
        stream: _firestoreService.streamUserStats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.burgundy),
            );
          }

          final stats = snapshot.data ?? UserStatsModel.empty();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cartão de Patente do Leitor (Estilo Certificado Vintage)
                _buildReaderRankCard(stats),
                const SizedBox(height: 20),

                // Título da Seção
                Text(
                  'Registro da Biblioteca',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.leatherBrown,
                  ),
                ),
                const SizedBox(height: 12),

                // Cartões de Estatísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Livros Lidos',
                        value: '${stats.livrosLidos}',
                        subtitle: 'Volumes concluídos',
                        icon: Icons.auto_stories,
                        accentColor: AppColors.burgundy,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Páginas Lidas',
                        value: '${stats.paginasLidas}',
                        subtitle: 'Páginas devoradas',
                        icon: Icons.history_edu,
                        accentColor: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card Informativo de Média
                if (stats.livrosLidos > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.parchmentCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.parchmentBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: AppColors.antiqueGold, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Média por Livro',
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.leatherBrown,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${(stats.paginasLidas / stats.livrosLidos).toStringAsFixed(0)} páginas em média por volume lido.',
                                style: GoogleFonts.lora(
                                  fontSize: 13,
                                  color: AppColors.sepiaText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Caixa Didática Explicativa da Cloud Function
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.parchmentWarm.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.antiqueGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_sync_outlined, color: AppColors.burgundy, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Automação Firebase Cloud Functions',
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.burgundy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estas estatísticas são mantidas e calculadas automaticamente no servidor '
                        'pela Cloud Function "onBookUpdated" sempre que o status de um livro é alterado para "Lido".',
                        style: GoogleFonts.lora(
                          fontSize: 12.5,
                          color: AppColors.sepiaText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de Sincronização / Recálculo de Fallback
                Center(
                  child: TextButton.icon(
                    onPressed: _isRecalculating ? null : () => _handleManualSync(userId),
                    icon: _isRecalculating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 18, color: AppColors.sepiaMuted),
                    label: Text(
                      'Sincronizar / Recalcular Manualmente',
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        color: AppColors.sepiaMuted,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Constrói o cartão de patente do leitor com brasão e medalha vintage
  Widget _buildReaderRankCard(UserStatsModel stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.antiqueGold, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.woodDark.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Medalhão Dourado
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.antiqueGold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.burgundyDark.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(stats.readerIcon, color: AppColors.goldLight, size: 38),
          ),
          const SizedBox(height: 14),
          Text(
            stats.readerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.leatherBrown,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stats.readerDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.sepiaText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os cartões individuais de métricas (Livros e Páginas)
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.parchmentBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.woodDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.leatherBrown,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.lora(
              fontSize: 11.5,
              color: AppColors.sepiaMuted,
            ),
          ),
        ],
      ),
    );
  }
}
