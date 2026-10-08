import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<_OnboardingPage> pages = const [
    _OnboardingPage(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Bem-vindo ao AUVIX',
      description:
          'Seu dinheiro, seus investimentos, seu controle.',
    ),
    _OnboardingPage(
      icon: Icons.savings_rounded,
      title: 'Organize seu dinheiro',
      description:
          'Acompanhe quanto você já guardou e planeje seus próximos aportes.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'Acompanhe seus investimentos',
      description:
          'Cadastre seus ativos e acompanhe a evolução da sua carteira.',
    ),
    _OnboardingPage(
      icon: Icons.calculate_rounded,
      title: 'Planeje o futuro',
      description:
          'Simule aportes, juros compostos, metas e diferentes cenários.',
    ),
    _OnboardingPage(
      icon: Icons.auto_graph_rounded,
      title: 'Tudo em um só lugar',
      description:
          'Agora você já conhece o AUVIX. Vamos começar?',
    ),
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _openLogin();
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _openLogin,
                child: const Text('Pular'),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AuvixTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AuvixTheme.accent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            size: 62,
                            color: AuvixTheme.accent,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AuvixTheme.muted,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? AuvixTheme.accent
                        : AuvixTheme.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: nextPage,
                  child: Text(
                    currentPage == pages.length - 1
                        ? 'COMEÇAR A USAR O AUVIX'
                        : 'CONTINUAR',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
