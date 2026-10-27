import 'package:firebase_auth/firebase_auth.dart';

/// Serviço responsável por gerenciar a autenticação com o Firebase Auth.
/// Segue a responsabilidade única: isolar todas as chamadas de login,
/// cadastro e encerramento de sessão em um único lugar.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna o usuário atualmente autenticado (ou null se deslogado)
  User? get currentUser => _auth.currentUser;

  /// Stream que notifica mudanças no estado de autenticação em tempo real
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Realiza login com E-mail e Senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      final errorStr = e.toString();
      if (errorStr.contains('CONFIGURATION_NOT_FOUND') ||
          errorStr.contains('configuration-not-found')) {
        throw 'O provedor de E-mail/Senha não está ativado no Firebase Console do projeto the-librarian-sofhia. Acesse o console do Firebase > Authentication > Sign-in method e ative "E-mail/senha".';
      }
      throw 'Ocorreu um erro inesperado ao tentar entrar: $e';
    }
  }

  /// Realiza o cadastro de uma nova conta de leitor
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is String) rethrow;
      final errorStr = e.toString();
      if (errorStr.contains('CONFIGURATION_NOT_FOUND') ||
          errorStr.contains('configuration-not-found')) {
        throw 'O provedor de E-mail/Senha não está ativado no Firebase Console do projeto the-librarian-sofhia. Acesse o console do Firebase > Authentication > Sign-in method e ative "E-mail/senha".';
      }
      throw 'Ocorreu um erro inesperado ao criar sua conta: $e';
    }
  }

  /// Encerra a sessão do usuário
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converte os códigos de erro técnicos do Firebase em mensagens didáticas em Português
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'O endereço de e-mail informado não é válido.';
      case 'user-disabled':
        return 'Esta conta de leitor foi desativada.';
      case 'user-not-found':
        return 'Nenhum leitor encontrado com este e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos. Por favor, verifique seus dados.';
      case 'email-already-in-use':
        return 'Este e-mail já está registrado na biblioteca.';
      case 'weak-password':
        return 'A senha é muito fraca. Digite pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Falha na conexão de rede. Verifique seu sinal de internet.';
      case 'too-many-requests':
        return 'Muitas tentativas sem sucesso. Aguarde alguns instantes.';
      case 'operation-not-allowed':
      case 'configuration-not-found':
      case 'CONFIGURATION_NOT_FOUND':
        return 'O provedor de E-mail/Senha não está ativado no Firebase Console do projeto the-librarian-sofhia. Acesse o console do Firebase > Authentication > Sign-in method e ative "E-mail/senha".';
      default:
        final msg = e.message ?? e.code;
        if (msg.contains('CONFIGURATION_NOT_FOUND') ||
            msg.contains('configuration-not-found')) {
          return 'O provedor de E-mail/Senha não está ativado no Firebase Console do projeto the-librarian-sofhia. Acesse o console do Firebase > Authentication > Sign-in method e ative "E-mail/senha".';
        }
        return 'Erro de autenticação: $msg';
    }
  }
}
