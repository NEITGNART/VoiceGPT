// Japanese
// Tiếng Nhật
// ja-JP-MayuNeural

// Chinese
// Tiếng Trung
// zh-HK-HiuGaaiNeural

// French
// Tiếng Pháp
// fr-FR-DeniseNeural

// Korean
// Tiếng Hàn
// ko-KR-GookMinNeural

// Spanish
// Tiếng Tây Ban Nha
// es-ES-ElviraNeural

// German
// Tiếng Đức
// de-DE-AmalaNeural

// Russian
// Tiếng Nag
// ru-RU-DmitryNeural

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, String> flags = {
  'en-US-AriaNeural': 'assets/images/english.png',
  'vi-VN-HoaiMyNeural': 'assets/images/vietnam.png',
  'ja-JP-MayuNeural': 'assets/images/japan.png',
  'zh-HK-HiuGaaiNeural': 'assets/images/china.png',
  'fr-FR-DeniseNeural': 'assets/images/france.png',
  'ko-KR-GookMinNeural': 'assets/images/south-korea.png',
  'es-ES-ElviraNeural': 'assets/images/spain.png',
  'de-DE-AmalaNeural': 'assets/images/germany.png',
  'ru-RU-DmitryNeural': 'assets/images/russia.png',
};

final Map<String, String> engLanguage = {
  'English': 'en-US-AriaNeural',
  'Japanese': 'ja-JP-MayuNeural',
  'Chinese': 'zh-HK-HiuGaaiNeural',
  'French': 'fr-FR-DeniseNeural',
  'Korean': 'ko-KR-GookMinNeural',
  'Spanish': 'es-ES-ElviraNeural',
  'German': 'de-DE-AmalaNeural',
  'Russian': 'ru-RU-DmitryNeural',
  'Vietnamese': 'vi-VN-HoaiMyNeural',
};

final Map<String, String> vnLanguage = {
  'Tiếng Anh': 'en-US-AriaNeural',
  'Tiếng Nhật': 'ja-JP-MayuNeural',
  'Tiếng Trung': 'zh-HK-HiuGaaiNeural',
  'Tiếng Pháp': 'fr-FR-DeniseNeural',
  'Tiếng Hàn': 'ko-KR-GookMinNeural',
  'Tiếng Tây Ban Nha': 'es-ES-ElviraNeural',
  'Tiếng Đức': 'de-DE-AmalaNeural',
  'Tiếng Nga': 'ru-RU-DmitryNeural',
  'Tiếng Việt': 'vi-VN-HoaiMyNeural'
};

class LanguageController extends GetxController {
  var language = 'English'.obs;
  var voiceName = 'en-US-AriaNeural'.obs;

  void changeLanguage(String lang) {
    language.value = lang;
    voiceName.value = engLanguage[lang]!;
  }

  void changeLanguageVn(String lang) {
    language.value = lang;
    voiceName.value = vnLanguage[lang]!;
  }

  String getLanguageName() {
    return language.value.tr;
  }
}

enum Constant {
  voiceAILanguageCode,
  voiceAILanguageName,
}

// save language code
Future<void> saveLanguageCode(String languageCode, String languageName) async {
  final prefs = Get.find<SharedPreferences>();
  prefs.setString(Constant.voiceAILanguageCode.name, languageCode);
  prefs.setString(Constant.voiceAILanguageName.name, languageName);
}

// get language code
Future<String> getLanguageCode() async {
  final prefs = Get.find<SharedPreferences>();
  return prefs.getString(Constant.voiceAILanguageCode.name) ??
      'en-US-AriaNeural';
}

// get language name
Future<String> getLanguageName() async {
  final prefs = Get.find<SharedPreferences>();
  return prefs.getString(Constant.voiceAILanguageName.name) ?? 'English';
}

class AIVoice extends StatelessWidget {
  const AIVoice({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            Text('voice_title'.tr),
          ],
        ),
      ),
      body: Column(
        children: [
          // get the language from the controller
          if ('voiceLanguage'.tr == 'vn') ...{
            Expanded(
              child: ListView.builder(
                // divider
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        // color
                        leading: Image.asset(
                          flags[vnLanguage.values.elementAt(index)]!,
                          width: 30,
                          height: 30,
                        ),
                        title: Text(vnLanguage.keys.elementAt(index)),
                        onTap: () async {
                          languageController.changeLanguageVn(
                              vnLanguage.keys.elementAt(index));

                          await saveLanguageCode(
                              vnLanguage.values.elementAt(index),
                              vnLanguage.keys.elementAt(index));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                              content: Text('change_voice_ai_success'.tr),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        thickness: 1,
                        color: Colors.blue,
                      ),
                    ],
                  );
                },
                itemCount: vnLanguage.length,
              ),
            ),
          } else ...{
            Expanded(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.asset(
                        flags[vnLanguage.values.elementAt(index)]!,
                        width: 30,
                        height: 30,
                      ),
                      title: Text(engLanguage.keys.elementAt(index)),
                      onTap: () async {
                        languageController
                            .changeLanguage(engLanguage.keys.elementAt(index));
                        await saveLanguageCode(
                            vnLanguage.values.elementAt(index),
                            vnLanguage.keys.elementAt(index));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                            content: Text('change_voice_ai_success'.tr),
                          ),
                        );
                      },
                    );
                  },
                  itemCount: engLanguage.length),
            ),
          }
        ],
      ),
    );
  }
}
