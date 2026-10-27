import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Gerenciador de estado de Autenticação (Provider).
/// Fornece o estado atual do usuário e métodos para login, cadastro e logout
/// para toda a árvore de widgets sem poluir a interface gráfica.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isGuestMode = false;
  String? _guestEmail;
  String? _guestUid;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _currentUser = _authService.currentUser;
    // Escuta alterações de login/logout em tempo real
    _authSubscription = _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _isGuestMode = false;
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('Aviso no stream de autenticação: $error');
    });
  }

  // Getters para a UI
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.uid ?? (_isGuestMode ? _guestUid : null);
  bool get isAuthenticated => _currentUser != null || _isGuestMode;
  bool get isGuestMode => _isGuestMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userEmail => _currentUser?.email ?? _guestEmail ?? 'Leitor Anônimo';

  /// Permite acesso no Modo Convidado / Demonstração
  void enterGuestMode([String? email]) {
    _isGuestMode = true;
    _guestEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim()
        : 'leitor.convidado@the-librarian.com';
    _guestUid = 'leitor_convidado_${DateTime.now().millisecondsSinceEpoch}';
    _errorMessage = null;
    notifyListeners();
  }

  /// Realiza o login do usuário
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isGuestMode = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Realiza o registro de um novo usuário
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isGuestMode = false;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  /// Desconecta o leitor do aplicativo
  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (_currentUser != null) {
        await _authService.signOut();
      }
      _isGuestMode = false;
      _guestEmail = null;
      _guestUid = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa a mensagem de erro
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
