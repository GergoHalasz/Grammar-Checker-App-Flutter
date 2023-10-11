import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:http/http.dart' as http;

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/helpers/api_helper.dart';
import 'package:grammar/core/models/grammar.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:info_popup/info_popup.dart';

class GrammarCheckResultScreen extends StatefulWidget {
  const GrammarCheckResultScreen(
      {Key? key, required this.result, required this.checkString})
      : super(key: key);
  static const routeName = '/grammnar_check_result_screen';
  final dynamic result;
  final String checkString;
  @override
  State<GrammarCheckResultScreen> createState() =>
      _GrammarCheckResultScreenState();
}

class _GrammarCheckResultScreenState extends State<GrammarCheckResultScreen> {
  List<TextSpan> spans = [];
  List<String> fixs = [];
  int numError = 0;
  bool isShowError = false;
  late Grammar grammar;
  late String correctedGrammar = "";
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage(
        "en-US"); // Set the language (you can change it based on your needs)
    await flutterTts.setPitch(1.0); // Set the pitch (1.0 is the default)
    await flutterTts.speak(text);
  }

  List<InlineSpan> compareText(bool isWrongText) {
    List<String> words1 = splitTextIntoWords(widget.checkString);
    List<String> words2 = splitTextIntoWords(widget.result);

    List<InlineSpan> formattedText = isWrongText
        ? underlineUnusedWords(words1, words2, isWrongText)
        : underlineUnusedWords(words2, words1, isWrongText);

    return formattedText;
  }

  List<String> splitTextIntoWords(String text) {
    return text.split(RegExp(r'\s+|(?<=[,.!?])'));
  }

  List<InlineSpan> underlineUnusedWords(
      List<String> words1, List<String> words2, bool isWrongText) {
    Set<String> uniqueWords2 = Set.from(words2);

    List<InlineSpan> formattedText = [];

    for (int i = 0; i < words1.length; i++) {
      String word = words1[i];

      if (!',!?'.contains(word)) {
        // Skip delimiters
        String trimmedWord = word.trim();

        if (trimmedWord.isNotEmpty) {
          if (!uniqueWords2.contains(trimmedWord)) {
            formattedText.add(TextSpan(
              text: trimmedWord,
              style: TextStyle(
                  decoration: isWrongText ? TextDecoration.underline : null,
                  color: isWrongText
                      ? ColorPalette.grammarColor
                      : ColorPalette.correctColor),
            ));
          } else {
            formattedText.add(TextSpan(text: trimmedWord));
          }

          if (i < words1.length - 1) {
            // Add a space unless it's the last word
            formattedText.add(TextSpan(text: ' '));
          }
        }
      }
    }

    return formattedText;
  }

  @override
  Widget build(BuildContext context) {
    final screnSize = MediaQuery.of(context).size;
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
      body: Container(
        color: ColorPalette.backgroundColor,
        padding: EdgeInsets.symmetric(
            horizontal: screnSize.width * 0.05,
            vertical: screnSize.height * 0.05),
        child: Column(children: <Widget>[
          SizedBox(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: ColorPalette.containerColor,
                      borderRadius: kDefaultBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFbfbfbf).withOpacity(0.3),
                          offset: Offset(4, 4),
                          blurRadius: 10.0,
                          spreadRadius: 3,
                        ),
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            height: screnSize.height * 0.08,
                            child: RichText(
                                text: TextSpan(
                              children: compareText(true),
                              style: DefaultTextStyle.of(context).style,
                            ))),
                        Divider(
                          thickness: 0.5,
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 8.0),
                            height: screnSize.height * 0.06,
                            child: RichText(
                                text: TextSpan(
                              children: compareText(false),
                              style: DefaultTextStyle.of(context).style,
                            ))),
                        SizedBox(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  child: Row(children: <Widget>[
                                    InkWell(
                                      child: Image(
                                          width: 24,
                                          image: AssetImage(
                                              'assets/images/icons/icon-voice.png')),
                                      onTap: () => speak(widget.result),
                                    ),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    InkWell(
                                      child: Image(
                                        image: AssetImage(
                                            'assets/images/icons/icon-copy.png'),
                                        width: 24,
                                      ),
                                      onTap: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: widget.result));
                                        EasyLoading.showToast(
                                            "Copied to clipboard!");
                                      },
                                    ),
                                  ]),
                                ),
                              ]),
                        ))
                      ])))
        ]),
      ),
    );
  }
}
