import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../constants/color_constants.dart';
import '../../../constants/language_constants.dart';

class GrammarParaphraseResultScreen extends StatefulWidget {
  const GrammarParaphraseResultScreen(
      {super.key, required this.result, required this.checkString});
  static const routeName = "/grammar_paraphrase_result_screen";
  final String result;
  final String checkString;
  @override
  State<GrammarParaphraseResultScreen> createState() =>
      _GrammarParaphraseResultScreenState();
}

class _GrammarParaphraseResultScreenState
    extends State<GrammarParaphraseResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          hoverColor: ColorPalette.primaryColor,
          icon: Icon(
            Symbols.chevron_left,
            color: ColorPalette.primaryColor,
            size: 36,
            weight: 900,
          ),
          onPressed: () {
            // Add navigation logic here to go back to the previous screen
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: ColorPalette.backgroundColor,
        title: Text(
          translation(context).grammar,
          style: TextStyle(
              color: ColorPalette.primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 26),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(child: Text(widget.result)),
    );
  }
}
