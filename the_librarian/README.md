# The Librarian - Estante de Livros Digital

Especificação dos Requisitos de Software (SRS) Estrutura Baseada no ISO/IEC/IEEE 29148:2018

## 1. Identificação do Documento

* **Projeto:** The Librarian – Estante de Livros Digital (Situação de Aprendizagem 2)
* **Versão:** 1.0.0
* **Data:** 2026-10-20
* **Autor:** Ana Sofhia

## 2. Introdução

### 2.1 Propósito

Documentação focada em descrever os requisitos funcionais, não-funcionais e regras de negócio do protótipo **The Librarian**, com foco no gerenciamento inteligente de leituras e na automação de estatísticas de progresso via backend em nuvem (Cloud Functions).

### 2.2 Escopo

A aplicação permite o cadastro e autenticação de usuários, busca de obras literárias integrada à **Google Books API**, organização de leituras em estantes virtuais e atualização automatizada de métricas de desempenho de leitura.

* **Conceitos Técnicos:** Arquitetura orientada a microsserviços/serverless (Firebase Cloud Functions), modelagem de dados NoSQL no Cloud Firestore, consumo de APIs externas e gerenciamento de estado reativo no Flutter.

### 2.3 Visão Geral

Este documento organiza o desenvolvimento em requisitos funcionais, não-funcionais e regras de negócio, garantindo a rastreabilidade entre o código desenvolvido e as necessidades operacionais do clube de leitura.

## 3. Requisitos Funcionais (RF)

| ID | Nome | Descrição |
| :--- | :--- | :--- |
| **RF01** | Autenticação de Usuários | Sistema seguro de login e registro para cada membro do clube utilizando o Firebase Authentication. |
| **RF02** | Busca de Livros | Integração com a Google Books API para permitir a pesquisa de títulos literários por nome ou autor. |
| **RF03** | Gerenciamento de Estantes | O usuário pode adicionar livros buscados a uma de três estantes virtuais: "Quero Ler", "Lendo" ou "Lidos", com persistência no Cloud Firestore. |
| **RF04** | Atualização de Status | Permitir que o usuário movimente dinamicamente os livros entre as estantes virtuais. |
| **RF05** | Painel "Minhas Estatísticas" | Tela dedicada no aplicativo que lê e exibe os dados agregados do documento de estatísticas do usuário. |

## 4. Requisitos Não-Funcionais (RNF)

| ID | Categoria | Descrição |
| :--- | :--- | :--- |
| **RNF01** | Segurança e Permissões | Regras de segurança robustas no Cloud Firestore para garantir isolamento, privacidade e integridade dos dados de leitura de cada usuário. |
| **RNF02** | Sincronização em Tempo Real | A interface do aplicativo deve refletir de forma fluida e reativa as alterações de estado dos livros e as métricas atualizadas pelo backend. |
| **RNF03** | Qualidade do Código Backend | O código da Cloud Function (JavaScript/TypeScript) deve ser limpo, legível, modular e seguro contra falhas de concorrência. |

## 5. Regras de Negócio (RN)

* **RN01 (Automação de Estatísticas via Cloud Function):** Uma Cloud Function acionada por gatilho (`onUpdate`) deve ser executada sempre que o status de um livro de um usuário for alterado para "Lido". A função deve ler os metadados do livro (como o número de páginas) e atualizar o documento de estatísticas do usuário (`/users/{userId}/stats/`), incrementando de forma automatizada os contadores `livrosLidos` e `paginasLidas`.
* **RN02 (Consistência de Estado no App):** O usuário deve conseguir alterar o status de seus livros nas estantes e essa mudança deve persistir corretamente no banco de dados e atualizar a interface sem necessidade de reinicialização manual.
* **RN03 (Integridade de Dados da API):** Somente livros válidos contendo os atributos essenciais retornados pela Google Books API (título, autores, capa e contagem de páginas) podem ser computados nas estatísticas de leitura.

## 6. Arquitetura do Sistema

* **Model:** Classes de domínio estruturadas (ex: `Livro` com atributos `title`, `authors`, `pageCount`, `status`, `thumbnail`; `EstatisticasUser` com `livrosLidos`, `paginasLidas`).
* **Controller / Serviços:** Camada de lógica de negócio e gerenciamento de estado no Flutter (utilizando Provider ou equivalentes) combinada com os serviços do Firebase (`AuthService`, `BookService`, `FirestoreService`).
* **Backend (Cloud Functions):** Script Node.js implantado para gerenciar a automação de eventos `onUpdate` no Firestore.
* **View (Telas):**
  * **Tela de Autenticação:** Interface de login e cadastro de novos membros.
  * **Tela de Busca e Catálogo:** Pesquisa de livros utilizando a Google Books API.
  * **Tela de Estantes:** Organização e listagem das leituras segmentadas por abas ("Quero Ler", "Lendo", "Lidos").
  * **Tela "Minhas Estatísticas":** Painel visual que exibe os totais de livros e páginas lidas gerados pela Cloud Function.

## 7. Prototipagem

* **Link:** https://stitch.google.com/projects/6098889514887033827

---

## 8. Estrutura do Código e Arquitetura Limpa

O projeto foi organizado com foco em clareza, manutenibilidade e separação de responsabilidades (Clean Architecture):

```text
lib/
├── core/                        # Núcleo da aplicação (Temas e Constantes)
│   ├── constants/
│   │   └── app_constants.dart   # Nomes de coleções e identificadores das estantes
│   └── theme/
│       ├── app_colors.dart      # Paleta de cores oficial vintage (Bordô, Couro, Ouro, Pergaminho)
│       └── app_theme.dart       # Tipografia serifada (Playfair Display & Lora) e componentes
├── models/                      # Modelos de dados com serialização
│   ├── book_model.dart          # Converte dados da Google Books API e Cloud Firestore
│   └── user_stats_model.dart    # Estrutura do documento de estatísticas /users/{userId}/stats/summary
├── services/                    # Camada de comunicação externa e infraestrutura
│   ├── auth_service.dart        # Firebase Authentication (Login, Registro e Logout)
│   ├── firestore_service.dart   # Operações CRUD e Streams reativas do Firestore
│   └── google_books_service.dart# Consumo HTTP da Google Books API com paginação
├── providers/                   # Gerenciamento de estado reativo (ChangeNotifier)
│   ├── auth_provider.dart       # Estado de sessão do leitor
│   └── books_provider.dart      # Estado de busca e sincronização de estantes
├── screens/                     # Camada de apresentação (UI / Visual)
│   ├── auth/                    # Fluxo de Autenticação tradicional
│   │   ├── auth_wrapper.dart    # Porteiro de navegação reativa (Logado vs Deslogado)
│   │   ├── login_screen.dart    # Tela de Login com estética vintage
│   │   └── register_screen.dart # Tela de Cadastro de novo leitor
│   ├── home/
│   │   └── home_screen.dart     # Shell principal com navegação inferior e perfil
│   ├── shelves/                 # Estantes Virtuais
│   │   ├── shelves_screen.dart  # Abas "Quero Ler", "Lendo" e "Lidos" em tempo real
│   │   └── widgets/
│   │       ├── book_shelf_card.dart     # Card com lombada decorativa de livro
│   │       └── change_shelf_dialog.dart # Modal para movimentar ou remover livros
│   ├── search/                  # Catálogo & Busca
│   │   ├── search_screen.dart   # Busca por título/autor com tags rápidas
│   │   └── widgets/
│   │       └── search_book_card.dart    # Card com capa, autor e ação de estante
│   └── stats/                   # Dashboard de Métricas
│       └── stats_screen.dart    # Exibição de Livros e Páginas Lidas com títulos de leitor
├── firebase_options.dart        # Configuração do Firebase CLI
└── main.dart                    # Inicialização e injeção do MultiProvider

functions/                       # Backend Serverless (Firebase Cloud Functions)
├── package.json                 # Dependências (firebase-admin e firebase-functions)
├── index.js                     # Função `onBookUpdated` que calcula páginas automaticamente
└── README.md                    # Instruções de teste e deploy da função
```

## 9. Como Executar o Projeto

### Pré-requisitos
- Flutter SDK (versão 3.13 ou superior)
- Node.js (versão 18 para as Cloud Functions)

### Executando o Aplicativo Flutter
```bash
# 1. Instalar as dependências do Flutter
flutter pub get

# 2. Executar no emulador Android ou dispositivo conectado
flutter run
```

### Implantando as Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```