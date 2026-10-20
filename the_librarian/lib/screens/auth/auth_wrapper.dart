import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// O AuthWrapper atua como um "porteiro" da aplicação.
/// Ele escuta o [AuthProvider]:
/// - Se o leitor estiver logado, exibe a tela principal [HomeScreen].
/// - Se o leitor estiver deslogado, direciona para o [LoginScreen].
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Se estiver no processo de login/logout inicial, pode exibir uma tela de carregamento suave
    if (authProvider.isLoading && authProvider.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
