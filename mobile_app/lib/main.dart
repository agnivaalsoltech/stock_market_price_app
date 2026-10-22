import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'services/theme_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/main_navigation/main_navigation_screen.dart';
import 'screens/stock_detail/stock_detail_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/signup_flow_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().init();
  await AuthService().init();
  runApp(const MarketPulseApp());
}

class MarketPulseApp extends StatelessWidget {
  const MarketPulseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'MarketPulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeService().themeMode,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.home: (context) => const MainNavigationScreen(initialIndex: 0),
            AppRoutes.markets: (context) => const MainNavigationScreen(initialIndex: 1),
            AppRoutes.stockDetail: (context) => const StockDetailScreen(),
            AppRoutes.auth: (context) => const AuthScreen(),
            AppRoutes.signupFlow: (context) => const SignupFlowScreen(),
            AppRoutes.portfolio: (context) => const MainNavigationScreen(initialIndex: 2),
            AppRoutes.pro: (context) => const MainNavigationScreen(initialIndex: 3),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.profile: (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
