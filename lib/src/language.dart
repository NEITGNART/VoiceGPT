import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': {
          'greeting': 'Xin chào',
          'setting': 'Cài đặt ứng dụng',
          'language': 'Ngôn ngữ',
          'changeLanguage': 'Thay đổi ngôn ngữ',
          'code': 'VN',
          'voiceName': 'vi-VN-HoaiMyNeural',
          'currentLanguage': 'Tiếng Việt',
          'hint': 'Gõ hoặc dùng giọng nói',
          'botname': 'Trợ lý ảo BardGPT',
          'welcome': 'Chào bạn, tôi là BardGPT',
          'nav_chat': 'Nhắn tin',
          'contact': 'Liên lạc',
          'waiting': 'Tin nhắn đang được tải về...',
          'autoVoice': 'Tự động phát âm',
          'voice': 'Giọng nói ghi âm',
          'longMessage': 'Tin nhắn quá dài!',
          'changeVoiceSuccess':
              'Thay đổi ngôn ngữ ghi âm giọng nói thành công!',
          'voiceLanguage': 'vn',
          'voice_title': 'Giọng đọc AI',
          'change_voice_ai_success': 'Thay đổi giọng đọc AI thành công!',
        },
        'en_US': {
          'greeting': 'Hello',
          'setting': 'App Setting',
          'language': 'Language',
          'changeLanguage': 'Change Language',
          'code': 'EN',
          'voiceName': 'en-US-AriaNeural',
          'currentLanguage': 'English',
          'hint': 'Type or Press the Mic',
          'botname': 'Super Bard Bot',
          'welcome': 'Welcome to BardGPT',
          'nav_chat': 'Chat with BardGPT',
          'contact': 'Contact',
          'waiting': 'Waiting for response...',
          'autoVoice': 'Auto Voice',
          'voice': 'Voice Record',
          'longMessage': 'Message is too long!',
          'changeVoiceSuccess': 'Change voice record language success!',
          'voiceLanguage': 'en',
          'voice_title': 'AI Voice',
          'change_voice_ai_success': 'Change AI voice successfully!',
        },
      };
}
