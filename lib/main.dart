import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/theme_data.dart';
import 'package:grammar/core/representation/screens/splash_screen.dart';
import 'package:grammar/routes.dart';

import 'package:provider/provider.dart';
import 'core/constants/language_constants.dart';
import 'core/provider/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ColorPalette.backgroundColor, // Change this color to your desired color
        statusBarIconBrightness: Brightness.dark
      ),
    );
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeNotifier())],
      child: Consumer(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('ja'),
            theme: ThemeData(fontFamily: 'MarkPro'),
            onGenerateRoute: Routes.generateRoute,
            initialRoute: SpashScreen.routeName,
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}
