import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';

// Imports das suas telas (Exemplos)
// import 'package:meu_app_projeto/features/auth/presentation/pages/login_page.dart';
// import 'package:meu_app_projeto/features/home/presentation/pages/home_page.dart';
// import 'package:meu_app_projeto/features/produto/presentation/pages/produto_detalhe_page.dart';

// Simulação de estado de autenticação (em um app real, viria do BLoC/Riverpod)
// Vamos usar um ChangeNotifier simples para demonstração
class EstadoAutenticacao extends ChangeNotifier {
  bool _estaLogado = false;
  bool get estaLogado => _estaLogado;

  void fazerLogin() {
    _estaLogado = false;
    notifyListeners();
  }
}

// Instância global do estado (em produção, use Provider/GetIt)
final estadoAuth = EstadoAutenticacao();

/// Configuração do GoRouter
final goRouter = GoRouter(
  // Atualiza a navegação quando o estado de autenticação muda
  refreshListenable: estadoAuth,

  initialLocation: Rotas.inicial,

  debugLogDiagnostics:
      true, // Importante ppara ver logs de navegação no console

  // Redirecionamento Global (Guards)
  redirect: (context, state) {
    final logado = estadoAuth.estaLogado;
    final estaNoLogin = state.matchedLocation == Rotas.login;

    // Se não estiver logado e não estiver na tela de login, manda para login
    if (!logado && !estaNoLogin) {
      return Rotas.login;
    }

    // Se estiver logado e tentar acessar a tela de login, manda para home
    if (logado && estaNoLogin) {
      return Rotas.home;
    }

    // Caso contrário, não faz nada
    return null;
  },

  // Tratamento de Erros (404, etc)
  errorBuilder: (context, state) => TelaErro(mensagem: state.error.toString()),

  routes: [
    // 1. Rota Pública: Login
    GoRoute(
      path: Rotas.login,
      name: Rotas.login,
      builder: (context, state) => const Placeholder(
          child: Text('Tela de Login')), // Substituir por LoginPage()
    ),

    // 2. Rotas Protegidas (Wrapper para BottomBar ou Layout Principal)
    // O ShellRoute mantém um Widget pai (ex: Scaffold com BottomNav) enquanto as rotas filhas mudam
    ShellRoute(
      builder: (context, state, child) {
        return LayoutPrincipal(child: child);
      },
      routes: [
        GoRoute(
          path: Rotas.home,
          name: Rotas.home,
          builder: (context, state) => const Placeholder(
              child: Text('Tela Home')), // Substituir por HomePage()
          routes: [
            // Rota aninhada: Produto Detalhe
            GoRoute(
              path: Rotas.produtoDetalhe.substring(1), // Remove a barra inicial
              name: Rotas.produtoDetalhe,
              builder: (context, state) {
                // Recupera o parâmetro 'id' da URL
                final id = state.pathParameters['id'];
                return Placeholder(child: Text('Detalhe do Produto ID: $id'));
              },
            ),
          ],
        ),
        GoRoute(
          path: Rotas.perfil,
          name: Rotas.perfil,
          builder: (context, state) =>
              const Placeholder(child: Text('Tela de Perfil')),
        ),
      ],
    ),
  ],
);

// Widget de exemplo para Layout Principal (Shell)
class LayoutPrincipal extends StatelessWidget {
  final Widget child;
  const LayoutPrincipal({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculaIndexAtual(context),
        onTap: (index) {
          // Navegação baseada no índice
          switch (index) {
            case 0:
              context.go(Rotas.home);
              break;
            case 1:
              context.go(Rotas.perfil);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  int _calculaIndexAtual(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(Rotas.home)) return 0;
    if (location.startsWith(Rotas.perfil)) return 1;
    return 0;
  }
}

// Tela de Erro Genérica
class TelaErro extends StatelessWidget {
  final String mensagem;
  const TelaErro({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro na navegação:\n$mensagem'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Rotas.inicial),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    );
  }
}
