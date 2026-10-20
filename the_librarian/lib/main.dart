import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/books_provider.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  // Garante que os bindings do Flutter estejam inicializados antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização segura do Firebase com as opções do projeto
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Nota de inicialização do Firebase: $e');
    // Fallback para inicialização genérica
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }

  runApp(const TheLibrarianApp());
}

/// Widget raiz da aplicação The Librarian.
/// Configura o MultiProvider para injeção de dependências e aplica o tema Vintage.
class TheLibrarianApp extends StatelessWidget {
  const TheLibrarianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provedor de Estado de Autenticação (Firebase Auth)
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Provedor de Estado de Busca e Estantes (Google Books & Firestore)
        ChangeNotifierProvider(create: (_) => BooksProvider()),
      ],
      child: MaterialApp(
        title: 'The Librarian',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.vintageTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
