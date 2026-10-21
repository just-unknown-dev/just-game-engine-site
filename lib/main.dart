import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_game_engine_site/app/core/services/remote_config_service.dart';
import 'package:just_game_engine_site/app/core/theme/app_palette.dart';
import 'package:just_game_engine_site/app/core/theme/app_theme.dart';
import 'package:just_game_engine_site/app/core/theme/theme_cubit.dart';
import 'package:just_game_engine_site/app/routes/app_router.dart';

import 'firebase_options.dart';

final _appRouter = AppRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Fonts are fetched once, up front, while the loader shows.
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  RemoteConfigService.instance.initialize();
  runApp(BlocProvider(create: (_) => ThemeCubit(), child: const MyApp()));
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
    _loadFonts();
  }

  /// Every family and weight the site uses, so text doesn't swap fonts
  /// after the first frame.
  Future<void> _loadFonts() async {
    GoogleFonts.config.allowRuntimeFetching = true;
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.majorMonoDisplay(),
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500),
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
        GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        GoogleFonts.inter(),
        GoogleFonts.inter(fontWeight: FontWeight.w500),
        GoogleFonts.inter(fontWeight: FontWeight.w600),
        GoogleFonts.inter(fontWeight: FontWeight.w700),
        GoogleFonts.firaCode(),
      ]);
    } catch (e) {
      // A font that fails to load falls back to the system font.
      debugPrint('Font preload failed: $e');
    }
    GoogleFonts.config.allowRuntimeFetching = false;
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeCubit>().state;
    return MaterialApp.router(
      title: 'Just Game Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 220),
      routerConfig: _appRouter.config(),
      builder: (context, child) {
        if (!_isReady) return const _AppLoader();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Shown while fonts load; matches the HTML loader in web/index.html.
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ColoredBox(
      color: p.bg,
      child: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: p.accent,
            backgroundColor: p.accent.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}
