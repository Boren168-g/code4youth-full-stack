import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'screens/auth/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

/// Root of the app.
class Code4YouthApp extends StatelessWidget {
  const Code4YouthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();

    return MaterialApp(
      title: 'Code4Youth',
      debugShowCheckedModeBanner: false,

      // Both themes are defined from the outset. Dark mode is not a later
      // addition — students study at night.
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: state.themeMode,

      locale: state.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (BuildContext context, Widget? child) {
        // Body text never drops below 16 sp, and the platform text scale is
        // capped so a large-font device cannot break the layouts.
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const SplashScreen(),
    );
  }
}
