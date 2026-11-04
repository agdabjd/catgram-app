# catgram_app

### Etapa 1 — Login e Cadastro

Nesta etapa, foi desenvolvida a estrutura inicial do aplicativo **CatGram**, utilizando Flutter e Firebase, com o objetivo de permitir o cadastro e a autenticação de usuários.

Foram implementadas as seguintes funcionalidades:

- **Tela de login:** permite que usuários cadastrados acessem o aplicativo utilizando e-mail e senha.
- **Tela de cadastro:** permite criar uma conta informando nome de exibição, nome de usuário, e-mail e senha.
- **Validação de dados:** verifica o preenchimento dos campos, o formato do e-mail, o tamanho mínimo da senha e a disponibilidade do nome de usuário.
- **Autenticação com Firebase:** utilização do Firebase Authentication para criar contas e realizar o login por e-mail e senha.
- **Armazenamento de informações:** utilização do Cloud Firestore para armazenar os dados dos perfis e controlar a disponibilidade dos nomes de usuário.
- **Controle de sessão:** identificação automática de usuários autenticados, direcionando-os para a tela inicial do aplicativo.
- **Encerramento de sessão:** implementação da opção de sair da conta.

Também foi desenvolvida a identidade visual inicial do CatGram, com cores, elementos e telas personalizadas.

Ao finalizar esta etapa, o aplicativo permite realizar o cadastro de novos usuários, efetuar login, acessar a tela inicial e encerrar a sessão.

### Prints das telas

**Tela de Login**

![Tela de Login](prints/tela-login.png)

**Tela de Cadastro**

![Tela de Cadastro](prints/tela-cadastro.png)

**Validação de Cadastro**

![Validação](prints/validacao.png)

**Cadastro Concluído**

![Cadastro Concluído](prints/cadastro-concluido.png)
