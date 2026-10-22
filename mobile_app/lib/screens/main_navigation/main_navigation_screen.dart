import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/floating_nav_bar.dart';
import '../home/home_screen.dart';
import '../markets/markets_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../pro/pro_screen.dart';

/// Root navigation shell that houses Home, Markets, Portfolio, and Pro with a persistent floating bottom navigation dock.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  /// Helper to switch tabs from anywhere within the widget tree
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationScreenState>();
    if (state != null) {
      state.switchTo(index);
    } else {
      if (index == 0) {
        Navigator.pushNamed(context, AppRoutes.home);
      } else if (index == 1) {
        Navigator.pushNamed(context, AppRoutes.markets);
      } else if (index == 2) {
        Navigator.pushNamed(context, AppRoutes.portfolio);
      } else if (index == 3) {
        Navigator.pushNamed(context, AppRoutes.pro);
      }
    }
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex >= 0 && widget.initialIndex <= 3)
        ? widget.initialIndex
        : 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args <= 3) {
      _currentIndex = args;
    }
  }

  void switchTo(int index) {
    if (index >= 0 && index <= 3 && _currentIndex != index && mounted) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(showBottomNav: false),
            MarketsScreen(),
            PortfolioScreen(),
            ProScreen(),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: _currentIndex,
          onTap: switchTo,
        ),
      ),
    );
  }
}
