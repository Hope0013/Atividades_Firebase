# The Librarian - Firebase Cloud Functions

Este diretório contém a função em nuvem que automatiza as estatísticas de leitura dos usuários.

## 📌 Como funciona a Cloud Function `onBookUpdated`?
1. Ela monitora o caminho Firestore: `users/{userId}/books/{bookId}` através do evento `.onUpdate()`.
2. Quando o status de um livro muda para `lido`:
   - Incrementa em `+1` o campo `livrosLidos` em `/users/{userId}/stats/summary`.
   - Incrementa no campo `paginasLidas` a quantidade de páginas do livro lido.
3. Se um livro for desmarcado de `lido` para `lendo` ou `quero_ler`:
   - Decrementa em `-1` o campo `livrosLidos` e subtrai as páginas correspondentes.

## 🚀 Como testar e implantar

### 1. Instalar as dependências do Node.js
Na raiz da pasta `functions`:
```bash
npm install
```

### 2. Testar localmente com os Emuladores do Firebase
```bash
npm run serve
```

### 3. Fazer o deploy para a nuvem do Firebase
```bash
firebase deploy --only functions
```
