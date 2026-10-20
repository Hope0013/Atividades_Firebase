import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:tarefas_list_firebase/screen/login_screen.dart';
import 'package:tarefas_list_firebase/screen/tarefa_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //vai verificar o estado da autenticação e redirecionar 
      //para tarefas se ja estiver logado ou login se não estiver logado
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot){
        //se exisitir algum dado de conexão estabelecida 
        if (snapshot.hasData){
          //redireciona para a tela de tarefas
          return TarefaScreen();
        }
        // se não => redireciona para a tela de login
        return LoginScreen();
      });
  }
}