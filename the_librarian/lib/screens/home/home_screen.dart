import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../services/firestore_service.dart';
import '../search/search_screen.dart';
import '../shelves/shelves_screen.dart';
import '../stats/stats_screen.dart';

/// Tela Principal da aplicação que engloba as 3 telas principais via Bottom Navigation:
/// 1. Minhas Estantes (Quero Ler, Lendo, Lidos)
/// 2. Buscar Livros (Google Books API)
/// 3. Minhas Estatísticas (Dashboard de Livros e Páginas Lidas)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<BookModel>>? _userBooksSub;

  @override
  void initState() {
    super.initState();
    // Inicia a sincronização dos livros do usuário para atualizar os status na busca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToUserBooks();
    });
  }

  void _listenToUserBooks() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);
      _userBooksSub = _firestoreService.streamAllUserBooks(userId).listen((books) {
        booksProvider.syncUserBooks(books);
      });
    }
  }

  @override
  void dispose() {
    _userBooksSub?.cancel();
    super.dispose();
  }

  void _showLogoutDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.parchmentCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.parchmentBorder, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.burgundy),
            const SizedBox(width: 10),
            Text(
              'Perfil do Leitor',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: AppColors.leatherBrown,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conectado como:',
              style: GoogleFonts.lora(fontSize: 12, color: AppColors.sepiaMuted),
            ),
            const SizedBox(height: 4),
            Text(
              auth.userEmail,
              style: GoogleFonts.lora(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.leatherBrown,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Deseja realmente encerrar a sessão na biblioteca?',
              style: GoogleFonts.lora(fontSize: 13, color: AppColors.sepiaText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.lora(color: AppColors.sepiaText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () {
              Navigator.of(ctx).pop();
              auth.signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ShelvesScreen(
        onNavigateToSearch: () => setState(() => _currentIndex = 1),
      ),
      const SearchScreen(),
      const StatsScreen(),
    ];

    final titles = [
      'The Librarian',
      'Buscar Livros',
      'Minhas Estatísticas',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.antiqueGold, size: 24),
            const SizedBox(width: 8),
            Text(
              titles[_currentIndex],
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: AppColors.leatherBrown,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Meu Perfil',
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.leatherBrown),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.burgundy,
        unselectedItemColor: AppColors.sepiaMuted,
        backgroundColor: AppColors.parchmentWarm,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Estantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.military_tech_outlined),
            activeIcon: Icon(Icons.military_tech),
            label: 'Estatísticas',
          ),
        ],
      ),
    );
  }
}
