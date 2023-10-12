import 'package:flutter/material.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_result_screen.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_screen.dart';
import 'package:grammar/core/representation/screens/main_screen.dart';
import 'package:grammar/core/representation/screens/splash_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case SpashScreen.routeName:
        return MaterialPageRoute(builder: (context) => SpashScreen());
      case MainScreen.routeName:
        return MaterialPageRoute(builder: (context) => MainScreen());
      case GrammarCheckScreen.routeName:
        return MaterialPageRoute(builder: (context) => GrammarCheckScreen());
      case GrammarCheckResultScreen.routeName:
        var args = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => GrammarCheckResultScreen(
                  checkString: args['checkString'],
                  result: args['result'],
                ));
      default:
    }
    return MaterialPageRoute(
        builder: (context) => Scaffold(
              body: Text("No route defined"),
            ));
  }
}
