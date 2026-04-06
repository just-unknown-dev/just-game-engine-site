import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_game_engine_site/app/core/services/remote_config_service.dart';
import 'package:just_game_engine_site/app/core/theme/app_colors.dart';
import 'package:just_game_engine_site/app/core/theme/app_theme.dart';
import 'package:just_game_engine_site/app/routes/app_router.dart';

import 'firebase_options.dart';

final _appRouter = AppRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Fix 2: Disable runtime font fetching initially
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  RemoteConfigService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Pre-cache fonts while showing loader
    GoogleFonts.config.allowRuntimeFetching = true;
    await GoogleFonts.pendingFonts([
      GoogleFonts.majorMonoDisplay(),
      GoogleFonts.spaceGrotesk(),
      GoogleFonts.firaCode(),
    ]);
    GoogleFonts.config.allowRuntimeFetching = false;

    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Just Game Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _appRouter.config(),
      builder: (context, child) {
        // Fix 6: Show loading indicator while fonts load
        if (!_isReady) {
          return const _AppLoader();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Loading indicator shown during app initialization
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
