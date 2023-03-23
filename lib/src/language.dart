import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': {
          'greeting': 'Xin chào',
          'setting': 'Cài đặt',
          'language': 'Ngôn ngữ',
          'changeLanguage': 'Thay đổi ngôn ngữ',
          'code': 'VN',
          'voiceName': 'vi-VN-HoaiMyNeural',
        },
        'en_US': {
          'greeting': 'Hello',
          'setting': 'Setting',
          'language': 'Language',
          'changeLanguage': 'Change Language',
          'code': 'EN',
          'voiceName': 'en-US-AriaNeural',
        },
      };
}
