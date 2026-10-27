import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/books_provider.dart';

/// Modal estilo "Cartão de Empréstimo Vintage" para selecionar ou mudar a estante de um livro.
class ChangeShelfDialog extends StatelessWidget {
  final BookModel book;
  final String? currentShelf;

  const ChangeShelfDialog({
    super.key,
    required this.book,
    this.currentShelf,
  });

  /// Método estático utilitário para abrir o diálogo como um BottomSheet decorado
  static Future<void> show(
    BuildContext context, {
    required BookModel book,
    String? currentShelf,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeShelfDialog(
        book: book,
        currentShelf: currentShelf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final userId = auth.userId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.parchmentCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: AppColors.antiqueGold, width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de arraste
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.parchmentBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título do Diálogo
            Text(
              'Organizar Livro na Estante',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.leatherBrown,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lora(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.sepiaText,
              ),
            ),
            const SizedBox(height: 18),
            const Divider(color: AppColors.parchmentBorder),
            const SizedBox(height: 12),

            // Opções das 3 Estantes
            ...AppConstants.allShelves.map((shelfKey) {
              final isSelected = currentShelf == shelfKey;
              final label = AppConstants.getShelfLabel(shelfKey);
              final icon = AppConstants.getShelfIcon(shelfKey);
              final color = AppConstants.getShelfColor(shelfKey);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () async {
                    if (userId == null) return;
                    Navigator.of(context).pop();

                    await booksProvider.saveBookToShelf(
                      userId: userId,
                      book: book,
                      shelfKey: shelfKey,
                    );

                    if (context.mounted) {
                      final isLido = shelfKey == AppConstants.shelfLido;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: isLido ? AppColors.forestGreen : AppColors.leatherBrown,
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            children: [
                              Icon(
                                isLido ? Icons.military_tech : Icons.bookmark_added,
                                color: AppColors.goldLight,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isLido
                                      ? 'Parabéns pela leitura! Livro movido para "Lidos" e estatísticas atualizadas.'
                                      : 'Livro colocado na estante "$label".',
                                  style: GoogleFonts.lora(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : AppColors.parchmentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : AppColors.parchmentBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.leatherBrown,
                                ),
                              ),
                              Text(
                                _getShelfSubtitle(shelfKey),
                                style: GoogleFonts.lora(
                                  fontSize: 12,
                                  color: AppColors.sepiaMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Opção de Remover se já estiver na estante
            if (currentShelf != null) ...[
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: () async {
                  if (userId == null) return;
                  Navigator.of(context).pop();

                  await booksProvider.removeBook(
                    userId: userId,
                    bookId: book.id,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.errorRed,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Livro removido de suas estantes.',
                          style: GoogleFonts.lora(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                label: Text(
                  'Remover livro da biblioteca',
                  style: GoogleFonts.lora(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _getShelfSubtitle(String shelfKey) {
    switch (shelfKey) {
      case AppConstants.shelfQueroLer:
        return 'Obras guardadas para futuras leituras';
      case AppConstants.shelfLendo:
        return 'Páginas abertas no momento';
      case AppConstants.shelfLido:
        return 'Concluído! Computa páginas para suas estatísticas';
      default:
        return '';
    }
  }
}
