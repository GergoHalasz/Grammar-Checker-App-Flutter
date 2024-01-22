import 'dart:convert';
import 'dart:io';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grammar/core/helpers/speech_helper.dart';
import 'package:grammar/core/helpers/api_helper.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_result_screen.dart';
import 'package:grammar/service/admob.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_result_screen.dart';
import 'package:grammar/core/representation/widgets/button_widget.dart';

class GrammarCheckScreen extends StatefulWidget {
  const GrammarCheckScreen({super.key});
  static const routeName = '/grammnar_check_screen';

  @override
  State<GrammarCheckScreen> createState() => _GrammarCheckScreenState();
}

class _GrammarCheckScreenState extends State<GrammarCheckScreen> {
  bool speechEnabled = false;
  var currentBackPressTime;
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;

  final TextEditingController _checkController = TextEditingController();

  final openAI = OpenAI.instance.build(
      token: APIHelper.grammarCheck,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 10)));

  void pickGallery() async {
    PickedFile? image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    cropImage(File(image!.path));
  }

  void pickCamera() async {
    PickedFile? image =
        await ImagePicker().getImage(source: ImageSource.camera);
    cropImage(File(image!.path));
  }

  void cropImage(File filePath) async {
    CroppedFile? croppedFile = await ImageCropper()
        .cropImage(sourcePath: filePath.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: ColorPalette.primaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.ratio3x2,
        lockAspectRatio: false,
      )
    ]);
  }

  void _clearTextField() {
    _checkController.clear();
    setState(() {});
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) >= Duration(seconds: 2)) {
      currentBackPressTime = now;
      EasyLoading.showToast(translation(context).warningExit);
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();

    _createBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _createBannerAd() {
    _banner = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdState.bannerAdUnitId!,
        listener: AdState.listener,
        request: AdRequest())
      ..load();
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: ((ad, error) {
          ad.dispose();
          _createInterstitialAd();
        }),
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdState.interstitialAdUnitId!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd!.dispose();
            _createInterstitialAd();
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final screnSize = MediaQuery.of(context).size;
    ScrollController _scrollController = ScrollController();
    bool _isLoaded = false;

    // TODO: replace this test ad unit with your own ad unit.
    final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';

    return Scaffold(
      appBar: AppBar(
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
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          color: ColorPalette.backgroundColor,
          padding: EdgeInsets.symmetric(
              horizontal: screnSize.width * 0.05,
              vertical: screnSize.height * 0.015),
          child: SafeArea(
              child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: screnSize.height * 0.4,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                              kDefaultPadding, 0, 4, 0),
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
                          child: Column(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 4.0, right: 8.0, top: 4.0),
                              child: SizedBox(
                                height: screnSize.height * 0.3,
                                child: TextField(
                                  cursorWidth: 3.5,
                                  cursorRadius: Radius.circular(16),
                                  cursorColor: Color.fromARGB(255, 0, 180, 69),
                                  cursorHeight: 24,
                                  controller: _checkController,
                                  minLines: 5,
                                  maxLines: null,
                                  style: TextStyle(
                                      letterSpacing: 0.3,
                                      height: 1.5,
                                      fontSize: kDefaultFontSize,
                                      color: ColorPalette.textColor,
                                      fontWeight: FontWeight.w400),
                                  decoration: InputDecoration(
                                    hintText:
                                        translation(context).typeCheckGrammar,
                                    hintStyle: TextStyle(
                                        fontSize: kDefaultFontSize,
                                        color: ColorPalette.hintColor),
                                    labelStyle: TextStyle(
                                        fontSize: kDefaultFontSize,
                                        color: ColorPalette.textColor),
                                    hintMaxLines: 5,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  autofocus: false,
                                  onChanged: ((value) => setState(() {})),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: screnSize.height * 0.08,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _checkController.text != null
                                            ? SizedBox(
                                                child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    child: _checkController
                                                            .text.isEmpty
                                                        ? null
                                                        : IconButton(
                                                            icon: Image(
                                                              image: AssetImage(
                                                                  'assets/images/icons/icon-cancel.png'),
                                                              height: 28,
                                                            ),
                                                            onPressed: () {
                                                              _clearTextField();
                                                            },
                                                          ),
                                                  ),
                                                ],
                                              ))
                                            : Container(),
                                      ]),
                                ))
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 260,
                child: ButtonWidget(
                  title: translation(context).check,
                  ontap: () async {
                    _showInterstitialAd();
                    if (_checkController.text.isEmpty) {
                      return EasyLoading.showToast(
                          translation(context).requireMessage);
                    }
                    ConnectivityResult result =
                        await (Connectivity().checkConnectivity());
                    if (result == ConnectivityResult.none) {
                      return EasyLoading.showToast(
                          translation(context).disconnectMessage);
                    }
                    EasyLoading.show();
                    final request = ChatCompleteText(messages: [
                      Map.of({
                        "role": "system",
                        "content": translation(context).chatGPTSystemMessage
                      }),
                      Map.of({
                        "role": "user",
                        "content": '${_checkController.text}'
                      })
                    ], maxToken: 200, model: ChatModel.gptTurbo);

                    final response =
                        await openAI.onChatCompletion(request: request);
                    String completeText = response!.choices[0].message!.content;

                    EasyLoading.dismiss();

                    Navigator.of(context).pushNamed(
                        GrammarCheckResultScreen.routeName,
                        arguments: {
                          "checkString": _checkController.text,
                          "result": completeText
                        });
                  },
                ),
              ),
              KeyboardVisibilityBuilder(builder: (context, visible) {
                return visible == false
                    ? SizedBox(
                        height: screnSize.height * 0.15,
                      )
                    : Container();
              }),
            ],
          )),
        ),
      ),
      bottomNavigationBar: _banner == null
          ? Container()
          : Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
    );
  }
}
