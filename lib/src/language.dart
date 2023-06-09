import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': {
          'miss_chat': 'Tin nhắn trả về bị thiếu',
          'chat_limit_title': 'Thông báo',
          'chat_limit_content':
              'Nhấn vào biểu tượng bên phải để nhận thêm 30 lượt nhắn. Hoặc bạn có thể tạo lượt nhắn mới',
          'miss_chat_content':
              'Nhắn với chat từ "tiếp tục" để tiếp tục trò chuyện',
          'chat_history': 'Lịch sử nhắn tin',
          'empty_chat': 'Chưa có tin nhắn nào, hãy vào trò chuyện với AI ngay!',
          'auto_save': 'Tự động lưu tin nhắn',
          'service_err':
              'Hệ thống gặp sự cố, vui lòng gửi lại lời nhắn!. Xin lỗi vì sự bất tiện này!',
          'greeting': 'Xin chào',
          'setting': 'Cài đặt ứng dụng',
          'language': 'Ngôn ngữ',
          'changeLanguage': 'Thay đổi ngôn ngữ',
          'code': 'VN',
          'voiceName': 'vi-VN-HoaiMyNeural',
          'currentLanguage': 'Tiếng Việt',
          'hint': 'Gõ hoặc dùng giọng nói',
          'botname': 'Tin nhắn mới',
          'welcome': 'Chào bạn, tôi là BardGPT',
          'nav_chat': 'Nhắn tin với AI',
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
          'suggest': 'Đề xuất tính năng',
          'donation': 'Ủng hộ tôi',
          'tutorial': 'Hướng dẫn sử dụng',
          'network': 'Kết nối mạng',
          'network_value':
              'Hãy đảm bảo bạn đang kết nối mạng để sử dụng ứng dụng',
          'microphone': 'Tính năng ghi âm',
          'new_feature': 'Các tính năng mới',
          'tutorial_upcomming':
              'Chúng tôi sẽ cập các tính năng sớm nhất có thể, hãy gửi form đánh giá nếu gặp bất cứ lỗi nào để được giải quyết sớm nhất. Cảm ơn bạn đã sử dụng BardGPT',
          'microphone_value':
              'Hãy đảm bảo bạn đã cấp quyền truy cập vào Microphone. Hiện tại chúng tôi sử dụng ghi âm trong điện thoại của các bạn (mỗi điện thoại sẽ hỗ trợ các ngôn ngữ và độ chính xác khác nhau)',
          'chat': 'Nhắn tin',
          'chat_value':
              'Bạn có thể nhắn tin với BardGPT bằng cách gõ hoặc dùng giọng nói và nhắn với bất kỳ người nào khác',
          'thanks_title': 'Lời cảm ơn',
          'thanks':
              'Cảm ơn bạn đã sử dụng BardGPT. Với mong muốn đem lại những trải nghiệm tốt nhất cho bạn, chúng tôi rất mong nhận được những đánh giá của bạn để cải thiện ứng dụng. Hiện tại app đang duy trì bằng quảng cáo, vậy nên hy vọng những trải này không làm phiền bạn quá nhiều. Cảm ơn thầy Phạm Hoàng Hải và các thầy cô trường KHTN đã giúp em tạo ra project này và đăng lên trên store.',
          'intro_1': 'Trò chuyện với trí tuệ nhân tạo',
          'intro_1_content':
              'Hãy trò chuyện với trí tuệ nhân tạo và nhận câu trả lời cho các câu hỏi của bạn. Với mọi ngoại ngôn ngữ',
          'intro_2': 'Giọng nói trí tuệ nhân tạo',
          'intro_2_content':
              'Hỗ trợ đầu vào giọng nói và đầu ra giọng nói. Bạn có thể trò chuyện với trí tuệ nhân tạo bằng giọng nói lên tới 10 ngôn ngữ',
          'intro_3': 'Giọng nói tự động',
          'intro_3_content': 'Giọng nói tự động sẽ đọc tin nhắn cho bạn.',
          'intro_4': 'Quảng cáo',
          'intro_4_content':
              'Quảng cáo sẽ giúp chúng tôi duy trì ứng dụng. Chúng tôi hy vọng bạn hiểu.',
          'intro_5': 'Ngôn ngữ',
          'intro_5_content':
              'Hỗ trợ tiếng Anh và tiếng Việt. Chúng tôi sẽ thêm nhiều ngôn ngữ khác trong tương lai.',
          'intro_6':
              'Tạo các lời nhắn mẫu, giúp tiết kiệm thời gian khi gửi tin nhắn',
          'skip': 'Bỏ qua',
          'done': 'Hoàn thành',
          'intro': 'Giới thiệu',
          'note': 'Câu hỏi thường gặp',
          'sound_error':
              'Hiện tại không thể phát âm, chúng tôi sẽ khắc phục sớm nhất có thể. Vui lòng thử lại sau',
          'sound_title': 'Giọng đọc AI',
          'message_title': 'Giọng đọc',
          'message_long': 'Thời gian để đọc có thể lâu hơn bình thường',
          'common_error': 'Một lỗi phổ biến',
          'copied': 'Sao chép thành công',
          'txt_reuse': 'Nhắn tin nhanh',
          'no_template': 'Hãy bấm vào + để thêm mẫu',
          'create_template': 'Tạo bản mẫu',
          'template': 'Bản mẫu',
          'title': 'Tiêu đề',
          'title_hint': 'Nhập tiêu đề',
          'content': 'Nội dung',
          'content_hint': 'Nhập nội dung',
          'upd_template': 'Cập nhật bản mẫu',
          'del_all_template': 'Xóa tất cả bản mẫu',
          'del_all_chat': 'Xóa tất cả tin nhắn',
          'del_all_content':
              'Khi bấm xóa tất cả, bạn sẽ không thể khôi phục lại',
          'cancel': 'Hủy',
          'del': 'Xóa',
          'success': 'Thành công',
          'go_chat': 'Chat sẽ được chuyển tới trong 2 giây',
          'edit': 'Chỉnh sửa',
          'store_chat_title': 'Lưu cuộc hội thoại chat',
          'txt_reuse_content':
              'Bạn có thể lưu lại các tin nhắn để sử dụng lại sau này. Hãy vào phần tin nhắn nhanh, tạo bản mẫu. Đặt tên tiều đề (ngắn gọn) và nội dung. Sau đó bạn có thể gửi tin nhắn bằng cách bấm vào nút ở bên góc trái màn hình bên dưới cạnh bàn phím để sử dụng',
          'store_chat':
              'Hiện tại chúng tôi đang nâng cấp tính năng này, sẽ được cập nhật ở bản sau',
          'common_error_content':
              '''-Hệ thống không khả dụng\n +Hãy thử lại mở lại ứng dụng\n-Giọng đọc không khả dụng\n +Hiện tại hệ thống chúng tôi đang nâng cấp, do đó vấn đề này sẽ được khắc phục sau(Nếu giọng nói không hoạt động xin tính năng giọng nói tự động)\n\nHãy gửi form đánh giá để chúng tôi có thể khắc phục sớm nhất có thể''',
        },
        'en_US': {
          //       'txt_reuse_content':
          // 'Bạn có thể lưu lại các tin nhắn để sử dụng lại sau này. Hãy vào phần tin nhắn nhanh, tạo bản mẫu. Đặt tên tiều đề (ngắn gọn) và nội dung. Sau đó bạn có thể gửi tin nhắn bằng cách bấm vào nút ở bên góc trái màn hình bên dưới cạnh bàn phím để sử dụng',

          'chat_limit_title': 'Notification',
          'chat_limit_content':
              'Tap the icon on the right to get 30 more messages. Or you can create a new chat',
          'miss_chat': 'Miss chat',
          'miss_chat_content': 'Typing "continue" to continue the conversation',
          'chat_history': 'History',
          'del_all_chat': 'Delete all chat',
          'empty_chat': 'No chat history',
          'auto_save': 'Auto save chat',
          'txt_reuse_content':
              'You can save messages to reuse later. Go to the quick message section, create a template. Set the title (short) and content. Then you can send a message by pressing the button on the left side of the screen below the keyboard to use',
          'store_chat_title': 'Store chat',
          'store_chat':
              'We are upgrading this feature, it will be updated in the next version',
          'go_chat': 'Chat will be redirected in 2 second',
          'service_err':
              'Service now is in high demand, please try again!. Sorry for the inconvenience',
          'intro_6': 'Create templates to save time when sending messages',
          'del_all_template': 'Delete all templates',
          'del_all_content':
              'When you press delete all, you will not be able to restore it',
          'cancel': 'Cancel',
          'del': 'Delete',
          'title_hint': 'Enter title',
          'edit': 'Edit Template',
          'upd_template': 'Update template',
          'success': 'Success',
          'template': 'Templates',
          'message_title': 'AI Voice',
          'content': 'Message',
          'content_hint': 'Enter message',
          'title': 'Title',
          'create_template': 'Create a template',
          'no_template': 'Click + to add template',
          'txt_reuse': 'Quick Message',
          'advance_feature': 'Tính năng nâng cao',
          'message_long': 'Reading time may be longer than usual',
          'greeting': 'Hello',
          'setting': 'App Setting',
          'language': 'Language',
          'changeLanguage': 'Change Language',
          'code': 'EN',
          'voiceName': 'en-US-AriaNeural',
          'currentLanguage': 'English',
          'hint': 'Type or Press the Mic',
          'botname': 'New Chat',
          'welcome': 'Welcome to BardGPT',
          'nav_chat': 'Chat with AI',
          'contact': 'Contact',
          'waiting': 'Waiting for response...',
          'autoVoice': 'Auto Voice',
          'voice': 'Voice Record',
          'longMessage': 'Message is too long!',
          'changeVoiceSuccess': 'Change voice record language success!',
          'voiceLanguage': 'en',
          'voice_title': 'AI Voice',
          'change_voice_ai_success': 'Change AI voice successfully!',
          'suggest': 'Request new features',
          'donation': 'Buy me a coffee',
          'tutorial': 'Tutorial',
          'network': 'Network connection',
          'new_feature': 'New feature',
          'tutorial_upcomming':
              'Feel free to send us feedback if you have any issues',
          'network_value':
              'Please make sure you are connected to the network to use the app',
          'microphone': 'Voice record',
          'microphone_value':
              'Please make sure you have granted access to the microphone. Currently, we use the recording function on your phone (each phone will support different languages and accuracy) to respond to you.',
          'chat': 'Chat',
          'chat_value':
              'You can chat with BardGPT by typing or using voice and chat with anyone else.',
          'thanks_title': 'Acknowledgement',
          'thanks':
              'Thank you for using BardGPT. With the desire to bring you the best experience, we hope to receive your feedback to improve the app. Currently, the app is maintained by advertising, so we hope that these experiences do not bother you too much. And finally, I want to thank my teacher, Phạm Hoàng Hải at HCMUS for his support and guidance. Thank you!',
          'intro_1': 'Chat with AI',
          'intro_1_content':
              "Let's chat with AI and get answers to your questions with any languages",
          'intro_2': 'Voice AI',
          'intro_2_content':
              "Support voice input and voice output. You can chat with AI by voice.",
          'intro_3': 'Auto Voice',
          'intro_3_content': "Auto voice will read the message for you. ",
          'intro_4': 'Ads',
          'intro_4_content':
              "Ads will help us maintain the app. We hope you understand.",
          'intro_5': 'Language',
          'intro_5_content':
              "Support English and Vietnamese. We will add more languages in the future.",
          'skip': 'Skip',
          'done': 'Done',
          'intro': 'Introduction ',
          'note': 'FAQs',
          'copied': 'Copied',
          'sound_title': 'Voice AI',
          'sound_error':
              'Currently unable to play sound, we will fix it as soon as possible. Please try again later',
          'common_error': 'Common Error',
          'common_error_content':
              '''-System is not available\n +Please try to open the app again\n-Voice AI is not available\n +Currently our system is upgrading, so this issue will be fixed later(Please, turn off the automation voice, and try it on later)\n\nPlease send the feedback form so we can fix it as soon as possible''',
          // (Nếu giọng nói không hoạt động xin tính năng giọng nói tự động)
        },
      };
}
