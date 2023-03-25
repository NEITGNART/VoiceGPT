// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/common/constants.dart';
import 'package:chatgpt/src/pages/chat/representation/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'chat/representation/my_language.dart';
import 'chat/representation/my_voice_language.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late stt.SpeechToText _speech;
  late SharedPreferences sp;
  @override
  void initState() {
    super.initState();
    _speech = Get.find<stt.SpeechToText>();
    sp = Get.find<SharedPreferences>();
  }

  @override
  Widget build(BuildContext context) {
    final sp = Get.find<SharedPreferences>();
    final LanguageController languageController = Get.find();

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            Text(
              'setting'.tr,
              // align left
            ),
          ],
        ),
      ),
      body: Container(
        // background
        child: Column(
          children: [
            gapH20,
            GestureDetector(
              onTap: () {
                Get.to(const MyLanguage());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'language'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.black,
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
                Get.to(const AIVoice());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'voice_title'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.black,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over_outlined),
                      gapW20,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'autoVoice'.tr,
                            style: kTitle2Style.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  // switch
                  Switch(
                    value: sp.getBool('isAutoPlay') ?? false,
                    onChanged: (value) {
                      sp.setBool('isAutoPlay', value);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const MyVoiceLanguge());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.voice_chat),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'voice'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.black,
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
            // change language
            // ElevatedButton(
            //   onPressed: () {},
            //   child: const Text('Change Language'),
            // ),

            // InkWell(
            //   onTap: () {
            //     Get.updateLocale(const Locale('vi', 'VN'));
            //   },
            //   child: Row(children: [
            //     Text('language'.tr),
            //   ]),
            // ),
            Expanded(
                child: Center(
              child: SvgPicture.asset(
                'assets/setting.svg',
                fit: BoxFit.cover,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
