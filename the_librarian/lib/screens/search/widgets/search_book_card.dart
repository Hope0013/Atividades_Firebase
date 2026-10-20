import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/book_model.dart';
import '../../../providers/books_provider.dart';
import '../../shelves/widgets/change_shelf_dialog.dart';

/// Card de exibição para cada resultado retornado pela Google Books API.
/// Mostra a capa, título, autor, número de páginas e o botão para adicionar ou trocar de estante.
class SearchBookCard extends StatelessWidget {
  final BookModel book;

  const SearchBookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final currentShelf = booksProvider.getBookShelf(book.id);
    final hasShelf = currentShelf != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.parchmentCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasShelf ? AppColors.antiqueGold : AppColors.parchmentBorder,
          width: hasShelf ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.woodDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Capa do Livro
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 76,
                  height: 115,
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

            // Informações
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
                        const SizedBox(height: 6),
                        // Número de páginas
                        Row(
                          children: [
                            const Icon(Icons.menu_book, size: 14, color: AppColors.sepiaMuted),
                            const SizedBox(width: 4),
                            Text(
                              book.pageCountFormatted,
                              style: GoogleFonts.lora(
                                fontSize: 12,
                                color: AppColors.sepiaMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Linha inferior de Ação / Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasShelf) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.getShelfColor(currentShelf).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppConstants.getShelfColor(currentShelf),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppConstants.getShelfLabel(currentShelf),
                                  style: GoogleFonts.lora(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.getShelfColor(currentShelf),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ChangeShelfDialog.show(
                                context,
                                book: book,
                                currentShelf: currentShelf,
                              );
                            },
                            child: const Text('Mudar', style: TextStyle(fontSize: 12)),
                          ),
                        ] else ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.burgundy,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ChangeShelfDialog.show(
                                context,
                                book: book,
                                currentShelf: null,
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(
                              'Adicionar',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPlaceholderCover() {
    return Container(
      color: AppColors.parchmentWarm,
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 28, color: AppColors.antiqueGold),
          const SizedBox(height: 4),
          Text(
            'LIVRO',
            style: GoogleFonts.playfairDisplay(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppColors.sepiaMuted,
            ),
          ),
        ],
      ),
    );
  }
}
