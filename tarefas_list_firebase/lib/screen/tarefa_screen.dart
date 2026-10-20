import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TarefaScreen extends StatefulWidget {
  const TarefaScreen({super.key});

  @override
  State<TarefaScreen> createState() => _TarefaScreenState();
}

class _TarefaScreenState extends State<TarefaScreen> {
  //atributos
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth
      .instance
      .currentUser; //pegando dados do usuário atual autenticado
  final TextEditingController _tarefaController = TextEditingController();

  //CRUD de Tarefas
  //Adicionar Tarefas
  Future<void> _addTarefa() async {
    if (_tarefaController.text.isNotEmpty && _user != null) {
      await _db.collection("users").doc(_user.uid).collection("tarefas").add({
        "titulo": _tarefaController.text,
        "concluido": false,
        "criadaEm": Timestamp.now(),
      });
      _tarefaController.clear();
      Navigator.pop(context); //fechar a tela de Dialogo
    }
  }

  // Método para atualizar a tarefa
  Future<void> _mudarTarefa(String tarefaId, bool currentStatus) async {
    if (_user != null) {
      await _db
          .collection("users")
          .doc(_user.uid)
          .collection("tarefas")
          .doc(tarefaId)
          .update({"concluida": !currentStatus});
    }
  }

  // Método para deletar a tarefa
  Future<void> _deleteTarefa(String tarefaId) async {
    if (_user != null) {
      await _db
          .collection("users")
          .doc(_user.uid)
          .collection("tarefas")
          .doc(tarefaId)
          .delete();
    }
  }

  // Método para exibir a caixa de dialogo de criação da tarefa
  void _showAddTarefaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nova Tarefa"),
          content: TextField(
            controller: _tarefaController,
            autofocus: true,
            decoration: InputDecoration(labelText: "Nome da Tarefa"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            ElevatedButton(onPressed: _addTarefa, child: Text("Adicionar")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("users")
            .doc(_user?.uid)
            .collection("tarefas")
            .orderBy("criadaEm", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Nenhuma Tarefa Encontrada"));
          }
          var tarefas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              var tarefa = tarefas[index];
              var tarefaData = tarefa.data() as Map<String, dynamic>;
              bool concluida = tarefaData["concluida"] ?? false;
              return ListTile(
                title: Text(
                  tarefaData["titulo"],
                  style: TextStyle(
                    decoration: concluida
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                leading: Checkbox(
                  value: concluida,
                  onChanged: (bool? value) {
                    _mudarTarefa(tarefa.id, concluida);
                  },
                ),
                trailing: IconButton(
                  onPressed: () => _deleteTarefa(tarefa.id),
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              );
            });
        }),
        floatingActionButton: FloatingActionButton(onPressed: _showAddTarefaDialog, child: Icon(Icons.add),),
    );
  }
}
