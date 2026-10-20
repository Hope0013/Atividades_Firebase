import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';
import 'change_shelf_dialog.dart';

/// Card elegante com design vintage para exibir um livro dentro de uma estante.
class BookShelfCard extends StatelessWidget {
  final BookModel book;

  const BookShelfCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final shelfKey = book.status ?? AppConstants.shelfQueroLer;
    final shelfColor = AppConstants.getShelfColor(shelfKey);
    final shelfLabel = AppConstants.getShelfLabel(shelfKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.parchmentBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.woodDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Faixa decorativa lateral imitando a lombada do livro
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: shelfColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            // Capa do Livro
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 76,
                  height: 110,
                  color: AppColors.parchmentWarm,
                  child: book.hasThumbnail
                      ? Image.network(
                          book.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderCover(),
                ),
              ),
            ),

            // Informações do Livro
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.leatherBrown,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.authorsText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.sepiaText,
                          ),
                        ),
                      ],
                    ),

                    // Badges (Páginas e Estante) + Botão de Ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tag de Páginas
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.parchmentWarm,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.parchmentBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book, size: 12, color: AppColors.sepiaMuted),
                              const SizedBox(width: 4),
                              Text(
                                book.pageCountFormatted,
                                style: GoogleFonts.lora(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.sepiaText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botão Mover Estante
                        InkWell(
                          onTap: () {
                            ChangeShelfDialog.show(
                              context,
                              book: book,
                              currentShelf: book.status,
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: shelfColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: shelfColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  shelfLabel,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: shelfColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, size: 18, color: shelfColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder de capa vintage quando não há imagem disponível
  Widget _buildPlaceholderCover() {
    return Container(
      color: AppColors.parchmentWarm,
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 30, color: AppColors.antiqueGold),
          const SizedBox(height: 4),
          Text(
            'LIVRO',
            style: GoogleFonts.playfairDisplay(
              fontSize: 9,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: AppColors.sepiaMuted,
            ),
          ),
        ],
      ),
    );
  }
}
