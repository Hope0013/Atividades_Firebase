import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/books_provider.dart';
import 'widgets/search_book_card.dart';

/// Tela de Busca de Livros conectada diretamente à Google Books API.
/// Permite pesquisar obras por título, autor ou palavra-chave e adicioná-las às estantes.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final List<String> _quickSuggestions = [
    'Machado de Assis',
    'Clarice Lispector',
    'Dom Casmurro',
    'O Pequeno Príncipe',
    'Ficção Científica',
    'Orgulho e Preconceito',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    booksProvider.searchBooks(query);
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.parchmentLight,
      body: Column(
        children: [
          // Barra de Pesquisa Vintage
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: AppColors.parchmentWarm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _performSearch,
                  style: GoogleFonts.lora(color: AppColors.leatherBrown),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título ou autor...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.antiqueGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.sepiaMuted),
                            onPressed: () {
                              _searchController.clear();
                              booksProvider.clearSearch();
                            },
                          )
                        : null,
                  ),
                  onChanged: (text) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Sugestões Rápidas de Pesquisa (Tags)
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickSuggestions.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final suggestion = _quickSuggestions[index];
                      return ActionChip(
                        backgroundColor: AppColors.parchmentCard,
                        side: const BorderSide(color: AppColors.parchmentBorder),
                        label: Text(
                          suggestion,
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            color: AppColors.sepiaText,
                          ),
                        ),
                        onPressed: () {
                          _searchController.text = suggestion;
                          _performSearch(suggestion);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Área de Resultados
          Expanded(
            child: _buildResultsArea(booksProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsArea(BooksProvider provider) {
    if (provider.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.burgundy),
            const SizedBox(height: 16),
            Text(
              'Consultando o acervo da biblioteca...',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.sepiaText,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
              const SizedBox(height: 12),
              Text(
                'Falha na busca',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.leatherBrown,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                provider.searchError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontSize: 13, color: AppColors.sepiaMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _performSearch(_searchController.text),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.searchResults.isEmpty) {
      if (provider.lastQuery.isEmpty) {
        // Estado inicial
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.antiqueGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    size: 38,
                    color: AppColors.antiqueGold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Explore o Universo Literário',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.leatherBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Digite o nome de uma obra ou autor acima para consultar milhares de volumes na Open Library API.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: AppColors.sepiaText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Nenhum resultado encontrado para a busca
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 48, color: AppColors.sepiaMuted),
                const SizedBox(height: 12),
                Text(
                  'Nenhum livro encontrado',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.leatherBrown,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Não encontramos resultados para "${provider.lastQuery}". Tente verificar a grafia ou buscar por outro termo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(fontSize: 13, color: AppColors.sepiaMuted),
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final book = provider.searchResults[index];
        return SearchBookCard(book: book);
      },
    );
  }
}
