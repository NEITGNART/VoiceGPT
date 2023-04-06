// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/common/constants.dart';
import 'package:chatgpt/src/pages/chat/my_reuse_text.dart';
import 'package:chatgpt/src/pages/chat/representation/language_controller.dart';
import 'package:chatgpt/src/pages/history/representation/my_history_chat.dart';
import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../../network/admob_service_helper.dart';
import 'chat/representation/my_language.dart';
import 'chat/representation/my_voice_language.dart';
import 'faq/representation/my_faq.dart';
import 'home_page.dart';
import 'setting/representation/controller.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late stt.SpeechToText _speech;
  late SharedPreferences sp;

  final BannerAd myBanner = createBannerAds(AdMobService.settingBannerID ?? '');

  @override
  void initState() {
    super.initState();
    myBanner.load();
    _speech = Get.find<stt.SpeechToText>();
    sp = Get.find<SharedPreferences>();
    myBanner.load();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp = Get.find<SharedPreferences>();
    final LanguageController languageController = Get.find();
    final MoreSettingController c = Get.find();
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.blue,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Get.off(const HomePage());
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            Text(
              'setting'.tr,
              // align left
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              gapH20,
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyLanguage());
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language, color: Colors.blue),
                          gapW20,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'language'.tr,
                                style: kTitle2Style.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                'currentLanguage'.tr,
                                style: kCardSubtitleStyle.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const AIVoice());
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.record_voice_over_rounded,
                              color: Colors.blue),
                          gapW20,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'voice_title'.tr,
                                style: kTitle2Style.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                              // Text(
                              //   sp.getString('voiceRecord') ??
                              //       (Intl.getCurrentLocale() == 'en_US'
                              //           ? 'English'
                              //           : 'Tiếng Việt (Vietnamese)'),
                              //   style: kCardSubtitleStyle.copyWith(
                              //     color: Colors.grey,
                              //   ),

                              // observe from controller
                              Obx(
                                () => Text(
                                  languageController.getLanguageName(),
                                  style: kCardSubtitleStyle.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyVoiceLanguge());
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.voice_chat, color: Colors.blue),
                          gapW20,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'voice'.tr,
                                style: kTitle2Style.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                sp.getString('voiceRecord') ??
                                    (Intl.getCurrentLocale() == 'en_US'
                                        ? 'English'
                                        : 'Tiếng Việt (Vietnamese)'),
                                style: kCardSubtitleStyle.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                ),
              ),
              gapH16,
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                decoration: decoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over_outlined,
                            color: Colors.blue),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'autoVoice'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    // switch
                    Obx(
                      () => Switch(
                        value: c.isAutoPlayValue,
                        onChanged: (value) {
                          c.setAutoPlay(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              gapH16,
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyTextReuse());
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.quickreply, color: Colors.blue),
                      gapW20,
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'txt_reuse'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyHistoryChat());
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.history, color: Colors.blue),
                      gapW20,
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'chat_history'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // GestureDetector(
              //   onTap: () {
              //     Get.changeTheme(ThemeData.dark());
              //     setState(() {});
              //   },
              //   child: Container(
              //     margin:
              //         const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              //     padding: const EdgeInsets.all(10),
              //     decoration: decoration,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Row(
              //           children: [
              //             const Icon(Icons.dark_mode_outlined,
              //                 color: Colors.blue),
              //             gapW20,
              //             Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   'dark_mode'.tr,
              //                   style: kTitle2Style.copyWith(
              //                     color: Colors.blue,
              //                   ),
              //                 ),
              //               ],
              //             )
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              gapH16,
              GestureDetector(
                onTap: () {
                  Get.to(() => IntroductionScreen(
                        isTopSafeArea: true,
                        pages: [
                          PageViewModel(
                            title: 'intro_1'.tr,
                            body: 'intro_1_content'.tr,
                            image: Image.asset(
                              "assets/images/intro_1.png",
                            ),
                          ),
                          PageViewModel(
                            title: 'intro_2'.tr,
                            body: 'intro_2_content'.tr,
                            image: Image.asset(
                              "assets/images/intro_2.png",
                            ),
                          ),
                          PageViewModel(
                            title: 'txt_reuse'.tr,
                            body: 'intro_6'.tr,
                            image: Image.asset(
                              "assets/images/intro_6.png",
                            ),
                          ),
                          // PageViewModel(
                          //   title: 'intro_2'.tr,
                          //   body: 'intro_2_content'.tr,
                          //   image: Image.asset(
                          //     "assets/images/intro_2.png",
                          //   ),
                          // ),
                          PageViewModel(
                            title: 'intro_3'.tr,
                            body: 'intro_3_content'.tr,
                            image: Image.asset(
                              "assets/images/intro_3.png",
                            ),
                          ),
                          PageViewModel(
                            title: 'intro_5'.tr,
                            body: 'intro_5_content'.tr,
                            image: Image.asset(
                              "assets/images/intro_5.png",
                            ),
                          ),
                          PageViewModel(
                            title: 'intro_4'.tr,
                            body: 'intro_4_content'.tr,
                            image: Image.asset(
                              "assets/images/intro_4.png",
                            ),
                          ),
                        ],
                        onDone: () {
                          Get.back();
                        },
                        dotsDecorator: DotsDecorator(
                          size: const Size.square(10.0),
                          activeSize: const Size(20.0, 10.0),
                          activeColor: Colors.blue,
                          color: Colors.grey,
                          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
                          activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                        ),
                        showSkipButton: true,
                        skip: const Text('Skip'),
                        next: const Icon(Icons.arrow_forward),
                        done: const Text('Done',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ));
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.help_outline, color: Colors.blue),
                      gapW20,
                      Expanded(
                        child: Text(
                          'intro'.tr,
                          style: kTitle2Style.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const MyExpansionPanel());
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.interests_rounded, color: Colors.blue),
                      gapW20,
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'note'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () async {
                  try {
                    if (!await launchUrl(
                      Uri.parse(
                        'https://www.buymeacoffee.com/zzmanhtien3',
                      ),
                      mode: LaunchMode.externalApplication,
                    )) {}
                  } catch (e) {
                    // TODO: implement catch
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: decoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.blue),
                          gapW20,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'donation'.tr,
                                style: kTitle2Style.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: AdWidget(ad: myBanner),
      ),
    );
  }
}
