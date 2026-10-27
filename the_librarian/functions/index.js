/**
 * =============================================================================
 * THE LIBRARIAN - CLOUD FUNCTIONS (FIREBASE)
 * =============================================================================
 * 
 * Disciplina: Desenvolvimento de Sistemas (DS)
 * Finalidade: Automação no backend para cálculo de estatísticas de leitura.
 * 
 * Gatilho (Trigger):
 * - Executa automaticamente quando um documento em 'users/{userId}/books/{bookId}'
 *   sofre uma atualização (onUpdate).
 * 
 * Regra de Negócio:
 * - Sempre que o campo 'status' de um livro for alterado para 'lido',
 *   a função captura a quantidade de páginas do livro e incrementa de forma
 *   atômica o documento de resumo em '/users/{userId}/stats/summary'.
 * - Caso o leitor desmarque o livro de 'lido' para 'lendo' ou 'quero_ler',
 *   a função também decrementa os valores para manter os dados 100% corretos!
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inicializa o SDK de administração do Firebase
admin.initializeApp();
const db = admin.firestore();

/**
 * Função acionada na atualização de um livro do usuário.
 * Caminho do documento monitorado: users/{userId}/books/{bookId}
 */
exports.onBookUpdated = functions.firestore
  .document("users/{userId}/books/{bookId}")
  .onUpdate(async (change, context) => {
    // 1. Extração dos parâmetros da rota
    const userId = context.params.userId;
    const bookId = context.params.bookId;

    // 2. Obtenção dos dados ANTES e DEPOIS da alteração
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Se por algum motivo os dados não existirem, encerra a execução
    if (!beforeData || !afterData) {
      console.log(`Documento incompleto em ${userId}/${bookId}. Encerrando.`);
      return null;
    }

    const previousStatus = beforeData.status;
    const newStatus = afterData.status;

    // Se o status não mudou (ex: foi atualizada apenas a descrição ou título), não recalcula
    if (previousStatus === newStatus) {
      console.log(`Status inalterado (${newStatus}) para o livro ${bookId}.`);
      return null;
    }

    console.log(`Livro ${bookId} do leitor ${userId}: status mudou de '${previousStatus}' para '${newStatus}'.`);

    // Quantidade de páginas do livro (com fallback seguro para 0 se for nulo ou inválido)
    const pageCount = Number(afterData.pageCount || beforeData.pageCount || 0);

    let bookDelta = 0;
    let pagesDelta = 0;

    // CENÁRIO A: O livro foi marcado como "lido" (concluído)
    if (previousStatus !== "lido" && newStatus === "lido") {
      bookDelta = 1;
      pagesDelta = pageCount;
      console.log(`Incrementando: +1 livro e +${pageCount} páginas lidas.`);
    }
    // CENÁRIO B: O livro era "lido" e o leitor moveu de volta para "lendo" ou "quero_ler"
    else if (previousStatus === "lido" && newStatus !== "lido") {
      bookDelta = -1;
      pagesDelta = -pageCount;
      console.log(`Decrementando: -1 livro e -${pageCount} páginas lidas.`);
    }
    // CENÁRIO C: Mudança entre "quero_ler" e "lendo" (nenhum impacto nas páginas lidas)
    else {
      console.log(`Transição sem impacto nas estatísticas de livros concluídos.`);
      return null;
    }

    // 3. Referência ao documento de resumo de estatísticas do usuário
    // Caminho: /users/{userId}/stats/summary
    const statsRef = db
      .collection("users")
      .doc(userId)
      .collection("stats")
      .doc("summary");

    try {
      // 4. Atualização atômica usando FieldValue.increment
      // O 'set' com { merge: true } garante que se o documento ainda não existir,
      // ele será criado com segurança sem apagar outros campos.
      await statsRef.set(
        {
          livrosLidos: admin.firestore.FieldValue.increment(bookDelta),
          paginasLidas: admin.firestore.FieldValue.increment(pagesDelta),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log(`Estatísticas do leitor ${userId} atualizadas com sucesso!`);
      return { success: true, bookDelta, pagesDelta };
    } catch (error) {
      console.error(`Erro ao atualizar estatísticas do usuário ${userId}:`, error);
      throw new functions.https.HttpsError(
        "internal",
        "Erro ao atualizar estatísticas do leitor.",
        error
      );
    }
  });

/**
 * Função acionada na adição direta de um livro do usuário (onCreate).
 * Se o leitor adicionar um livro diretamente na estante "Lidos", incrementa o resumo.
 */
exports.onBookCreated = functions.firestore
  .document("users/{userId}/books/{bookId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const bookId = context.params.bookId;
    const data = snap.data();

    if (!data || data.status !== "lido") {
      return null;
    }

    const pageCount = Number(data.pageCount || 0);
    console.log(`Livro ${bookId} adicionado diretamente como 'lido' para ${userId}: +1 livro, +${pageCount} páginas.`);

    const statsRef = db
      .collection("users")
      .doc(userId)
      .collection("stats")
      .doc("summary");

    try {
      await statsRef.set(
        {
          livrosLidos: admin.firestore.FieldValue.increment(1),
          paginasLidas: admin.firestore.FieldValue.increment(pageCount),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      return { success: true };
    } catch (error) {
      console.error(`Erro ao incrementar estatísticas na criação do livro ${bookId}:`, error);
      return null;
    }
  });

/**
 * Função acionada na remoção de um livro do usuário (onDelete).
 * Se o livro removido estava marcado como "lido", decrementa o resumo.
 */
exports.onBookDeleted = functions.firestore
  .document("users/{userId}/books/{bookId}")
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    const bookId = context.params.bookId;
    const data = snap.data();

    if (!data || data.status !== "lido") {
      return null;
    }

    const pageCount = Number(data.pageCount || 0);
    console.log(`Livro ${bookId} ('lido') removido pelo leitor ${userId}: -1 livro, -${pageCount} páginas.`);

    const statsRef = db
      .collection("users")
      .doc(userId)
      .collection("stats")
      .doc("summary");

    try {
      await statsRef.set(
        {
          livrosLidos: admin.firestore.FieldValue.increment(-1),
          paginasLidas: admin.firestore.FieldValue.increment(-pageCount),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
      return { success: true };
    } catch (error) {
      console.error(`Erro ao decrementar estatísticas na exclusão do livro ${bookId}:`, error);
      return null;
    }
  });

