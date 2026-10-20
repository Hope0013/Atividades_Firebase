import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import 'widgets/book_shelf_card.dart';

/// Tela principal das Estantes Virtuais do The Librarian.
/// Organizada em 3 abas temáticas: "Quero Ler", "Lendo" e "Lidos".
/// Lê em tempo real (Stream) do Cloud Firestore em `/users/{userId}/books`.
class ShelvesScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSearch;

  const ShelvesScreen({super.key, this.onNavigateToSearch});

  @override
  State<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends State<ShelvesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Conecte-se para ver suas estantes.'));
    }

    return Scaffold(
      backgroundColor: AppColors.parchmentLight,
      body: Column(
        children: [
          // Barra de Abas Estilizada
          Container(
            color: AppColors.parchmentWarm,
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.burgundy,
              indicatorWeight: 3,
              labelColor: AppColors.burgundy,
              unselectedLabelColor: AppColors.sepiaMuted,
              tabs: [
                Tab(
                  icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                  text: AppConstants.getShelfLabel(AppConstants.shelfQueroLer),
                ),
                Tab(
                  icon: const Icon(Icons.menu_book_rounded, size: 20),
                  text: AppConstants.getShelfLabel(AppConstants.shelfLendo),
                ),
                Tab(
                  icon: const Icon(Icons.verified_outlined, size: 20),
                  text: AppConstants.getShelfLabel(AppConstants.shelfLido),
                ),
              ],
            ),
          ),

          // Conteúdo das Abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShelfTab(userId, AppConstants.shelfQueroLer),
                _buildShelfTab(userId, AppConstants.shelfLendo),
                _buildShelfTab(userId, AppConstants.shelfLido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói uma aba de estante reativa conectada ao Firestore
  Widget _buildShelfTab(String userId, String shelfKey) {
    return StreamBuilder<List<BookModel>>(
      stream: _firestoreService.streamBooksByShelf(
        userId: userId,
        shelfKey: shelfKey,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.burgundy),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.errorRed),
                  const SizedBox(height: 12),
                  Text(
                    'Erro ao carregar a estante.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.leatherBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(fontSize: 13, color: AppColors.sepiaMuted),
                  ),
                ],
              ),
            ),
          );
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return _buildEmptyShelf(shelfKey);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return BookShelfCard(book: book);
          },
        );
      },
    );
  }

  /// Exibe um estado vazio ilustrado e encorajador para o leitor
  Widget _buildEmptyShelf(String shelfKey) {
    final label = AppConstants.getShelfLabel(shelfKey);
    final icon = AppConstants.getShelfIcon(shelfKey);
    final color = AppConstants.getShelfColor(shelfKey);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 18),
            Text(
              'Estante "$label" Vazia',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.leatherBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              shelfKey == AppConstants.shelfLido
                  ? 'Você ainda não marcou nenhum livro como lido. Quando terminar uma leitura, ela aparecerá aqui e somará nas suas estatísticas!'
                  : 'Nenhuma obra arquivada nesta seção. Encontre novas histórias na barra de busca e adicione à sua coleção.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: AppColors.sepiaText,
                height: 1.4,
              ),
            ),
            if (widget.onNavigateToSearch != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.onNavigateToSearch,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Buscar Novos Livros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
