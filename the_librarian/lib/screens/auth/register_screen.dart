import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Tela de Cadastro / Registro de novo Leitor no The Librarian.
/// Utiliza autenticação por e-mail e senha no Firebase Auth.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @overridecd
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await auth.signUp(email, password);

      if (success && mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else if (!success && mounted && auth.errorMessage != null) {
        final errorMsg = auth.errorMessage!;
        final isConfigError = errorMsg.contains('Firebase Console') ||
            errorMsg.contains('CONFIGURATION_NOT_FOUND') ||
            errorMsg.contains('configuration-not-found');

        if (isConfigError) {
          _showFirebaseConfigDialog(email);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: GoogleFonts.lora(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  void _showFirebaseConfigDialog(String email) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.parchmentCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.antiqueGold, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings_suggest_rounded, color: AppColors.antiqueGold, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ativação do Firebase',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  color: AppColors.leatherBrown,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O provedor de E-mail/Senha ainda não está ativado no Firebase Console do projeto "the-librarian-sofhia".',
              style: GoogleFonts.lora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.leatherBrown,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Para ativar no Firebase:\n'
              '1. Acesse console.firebase.google.com\n'
              '2. Abra o projeto "the-librarian-sofhia"\n'
              '3. Vá em "Autenticação" (Authentication)\n'
              '4. Na aba "Sign-in method", ative "E-mail/senha" e salve.',
              style: GoogleFonts.lora(fontSize: 12, color: AppColors.sepiaText, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.antiqueGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dica: você pode entrar agora mesmo no Modo Demonstração para testar as estantes e estatísticas!',
                style: GoogleFonts.lora(fontSize: 12, color: AppColors.sepiaText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Fechar', style: GoogleFonts.lora(color: AppColors.sepiaText)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              auth.enterGuestMode(email);
            },
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Entrar no Modo Demo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.parchmentWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.leatherBrown),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Logo Oficial The Librarian
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.antiqueGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.woodDark.withValues(alpha: 0.14),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Registro de Leitor',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.leatherBrown,
                    ),
                  ),
                  Text(
                    'Crie sua estante virtual personalizada',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.sepiaText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cartão do Formulário
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.parchmentCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.parchmentBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.woodDark.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // E-mail
                          Text(
                            'E-mail',
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.leatherBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.lora(color: AppColors.leatherBrown),
                            decoration: const InputDecoration(
                              hintText: 'seu.email@leitor.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o seu e-mail.';
                              }
                              final trimmed = value.trim();
                              if (!trimmed.contains('@') ||
                                  !trimmed.contains('.') ||
                                  trimmed.startsWith('@') ||
                                  trimmed.endsWith('@') ||
                                  trimmed.endsWith('.')) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Senha
                          Text(
                            'Senha de Acesso',
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.leatherBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.lora(color: AppColors.leatherBrown),
                            decoration: InputDecoration(
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Informe uma senha.';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter no mínimo 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirmar Senha
                          Text(
                            'Confirmar Senha',
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.leatherBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: GoogleFonts.lora(color: AppColors.leatherBrown),
                            decoration: InputDecoration(
                              hintText: 'Repita sua senha',
                              prefixIcon: const Icon(Icons.lock_reset_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirme a sua senha.';
                              }
                              if (value != _passwordController.text) {
                                return 'As senhas não coincidem.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão de Cadastrar
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.forestGreen,
                              ),
                              onPressed: auth.isLoading ? null : _handleRegister,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.verified_outlined, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Criar Minha Estante',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Voltar ao Login
                  GestureDetector(
                    onTap: () {
                      auth.clearError();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Já possui uma estante? Voltar ao Login',
                      style: GoogleFonts.lora(
                        color: AppColors.sepiaText,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Modo Demonstração rápido
                  TextButton.icon(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      auth.enterGuestMode(email);
                    },
                    icon: const Icon(Icons.explore_outlined, color: AppColors.antiqueGold, size: 18),
                    label: Text(
                      'Entrar no Modo Demonstração (Convidado)',
                      style: GoogleFonts.lora(
                        color: AppColors.antiqueGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
