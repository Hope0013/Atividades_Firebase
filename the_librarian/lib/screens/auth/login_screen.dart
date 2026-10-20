import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

/// Tela de Autenticação / Login tradicional via E-mail e Senha.
/// Decorada com estilo Vintage, simulando a entrada de um Clube do Livro clássico.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (!success && mounted && auth.errorMessage != null) {
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
                    auth.errorMessage!,
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.parchmentWarm,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brasão e Cabeçalho Vintage
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.burgundy,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.antiqueGold, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.burgundyDark.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 44,
                      color: AppColors.parchmentWarm,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The Librarian',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.leatherBrown,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Estante de Livros Digital & Clube de Leitura',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.sepiaText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cartão com Textura de Pergaminho para o Formulário
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: AppColors.parchmentCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.parchmentBorder, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.woodDark.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Entrar na sua Biblioteca',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppColors.leatherBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Informe suas credenciais de leitor',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: 13,
                              color: AppColors.sepiaMuted,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Campo E-mail
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
                              hintText: 'exemplo@livro.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o seu e-mail de leitor.';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Informe um e-mail válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Campo Senha
                          Text(
                            'Senha',
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
                              hintText: '••••••••',
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
                                return 'Informe a sua senha.';
                              }
                              if (value.length < 6) {
                                return 'A senha deve conter no mínimo 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),

                          // Botão de Login
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
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
                                        const Icon(Icons.auto_stories, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Abrir Meus Livros',
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
                  const SizedBox(height: 24),

                  // Link para tela de Cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ainda não tem estante? ',
                        style: GoogleFonts.lora(
                          color: AppColors.sepiaText,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          auth.clearError();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Criar conta',
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Autenticação segura via Firebase Auth',
                    style: GoogleFonts.lora(
                      fontSize: 11,
                      color: AppColors.sepiaMuted,
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
