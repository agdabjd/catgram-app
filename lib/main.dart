import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

const Color catOrange = Color(0xFFD9A16F);
const Color catOrangeDark = Color(0xFF9B633D);
const Color catCream = Color(0xFFFFF8F1);
const Color catBrown = Color(0xFF49372C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CatGramApp());
}

class CatGramApp extends StatelessWidget {
  const CatGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CatGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: catCream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: catOrange,
          primary: catOrangeDark,
          surface: catCream,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEAD9C9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: catOrangeDark, width: 1.5),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class CatLogo extends StatelessWidget {
  const CatLogo({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF2D5B9),
        shape: BoxShape.circle,
      ),
      child: Text('🐱', style: TextStyle(fontSize: size * 0.52)),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // O AuthGate percebe o login e abre a tela inicial.
    } on FirebaseAuthException catch (error) {
      String message = 'Não foi possível entrar. Confira seus dados.';

      if (error.code == 'invalid-email') {
        message = 'O formato do e-mail não é válido.';
      } else if (error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        message = 'E-mail ou senha incorretos.';
      } else if (error.code == 'too-many-requests') {
        message = 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      }

      _showMessage(message);
    } catch (_) {
      _showMessage('Ocorreu um erro. Confira sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CatLogo()),
                    const SizedBox(height: 16),
                    const Text(
                      'CatGram',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: catBrown,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Um cantinho especial para os seus gatos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: catBrown),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe sua senha.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: catOrangeDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Ainda não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await CatGramAuthService().createAccount(
        displayName: _nameController.text.trim(),
        handle: _handleController.text.trim().toLowerCase(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Bem-vindo ao CatGram.')),
      );

      // O Firebase já autenticou a pessoa. Voltando à tela inicial,
      // o AuthGate mostrará a tela do CatGram.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on HandleAlreadyTakenException {
      _showMessage('Esse @usuário já está sendo usado. Escolha outro.');
    } on FirebaseAuthException catch (error) {
      String message = 'Não foi possível criar a conta. Tente novamente.';

      if (error.code == 'email-already-in-use') {
        message = 'Já existe uma conta com esse e-mail.';
      } else if (error.code == 'invalid-email') {
        message = 'O formato do e-mail não é válido.';
      } else if (error.code == 'weak-password') {
        message = 'A senha é fraca. Use pelo menos 6 caracteres.';
      }

      _showMessage(message);
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        _showMessage(
          'O Firestore recusou a operação. Confira as regras do banco.',
        );
      } else {
        _showMessage('Erro ao salvar o perfil: ${error.message ?? error.code}');
      }
    } catch (_) {
      _showMessage('Ocorreu um erro. Confira sua conexão e tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: catCream,
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: CatLogo(size: 66)),
                    const SizedBox(height: 12),
                    const Text(
                      'Entre para a comunidade!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: catBrown,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome de exibição',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu nome de exibição.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _handleController,
                      autocorrect: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9._]'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: '@usuário',
                        prefixText: '@',
                        prefixIcon: Icon(Icons.alternate_email),
                        hintText: 'mimi_laranja',
                      ),
                      validator: (value) {
                        final handle = value?.trim() ?? '';
                        if (!RegExp(r'^[a-zA-Z0-9._]{3,20}$')
                            .hasMatch(handle)) {
                          return 'Use 3–20 letras, números, ponto ou _.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _hidePassword = !_hidePassword);
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Use pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _loading ? null : _createAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: catOrangeDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatGramAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAccount({
    required String displayName,
    required String handle,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(displayName);

      final handleRef = _firestore.collection('handles').doc(handle);
      final profileRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final handleSnapshot = await transaction.get(handleRef);

        if (handleSnapshot.exists) {
          throw HandleAlreadyTakenException();
        }

        transaction.set(handleRef, {'uid': user.uid});
        transaction.set(profileRef, {
          'displayName': displayName,
          'username': '@$handle',
          'handleKey': handle,
          'email': email.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      // Se o perfil não puder ser criado, remove a conta Auth recém-criada
      // para evitar deixar uma conta incompleta.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Mantém o erro original para mostrar uma mensagem na tela.
        }
      }
      rethrow;
    }
  }
}

class HandleAlreadyTakenException implements Exception {}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: catCream,
        title: const Text('CatGram 🐾'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CatLogo(),
              const SizedBox(height: 18),
              const Text(
                'Miau! Você entrou no CatGram.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: catBrown,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (user != null)
                Text(
                  'Olá, ${user.displayName ?? user.email ?? 'pessoa usuária'}!',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Informe seu e-mail.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Digite um e-mail válido.';
  }
  return null;
}