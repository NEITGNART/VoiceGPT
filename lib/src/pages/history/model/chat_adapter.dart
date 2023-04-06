// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../models/chat.dart';

class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final typeId = 2;

  @override
  Chat read(BinaryReader reader) {
    final id = reader.readString();
    final msg = reader.readString();
    final chat = reader.readInt();
    return Chat(id: id, msg: msg, chat: chat);
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer.writeString(obj.id!);
    writer.writeString(obj.msg);
    writer.writeInt(obj.chat);
  }
}

class HiveBoxes {
  Future<Box<T>> openBox<T>(String name) async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatAdapter());
    return Hive.openBox<T>(name);
  }
}

class HistoryChatController extends GetxController {
  final RxList<Chat> chatList = RxList<Chat>([]);
  late Box<Chat> chatBox;

  @override
  void onInit() async {
    chatBox = await HiveBoxes().openBox<Chat>('chat_history');
    final chatList = chatBox.values.toList();
    chatList.assignAll(chatList);
    super.onInit();
  }

  void addChat(Chat chat) {
    chatBox.add(chat);
    chatList.add(chat);
  }

  void deleteAll() {
    chatBox.clear();
    chatList.clear();
  }
} 

// class HistoryChatController extends GetxController {
//   final ChatRepository _chatRepository = ChatRepository();
//   final String conversationId;
//   HistoryChatController(this.conversationId);
//   final RxList<Chat> _chatList = RxList<Chat>([]);

//   List<Chat> get chatList => _chatList.toList();

//   void addChat(Chat chat) {
//     _chatRepository.addChat(conversationId, chat);
//   }

//   @override
//   void onInit() {
//     // Watch for changes to the chat list in the conversation
//     _chatRepository.watchChat(conversationId).listen((chatList) {
//       // Update the chat list in the controller
//       _chatList.assignAll(chatList);
//     });
//     super.onInit();
//   }

//   @override
//   void onClose() async {
//     // Close the Hive box for the conversation
//     final chatBox = await _chatRepository.getChatBox(conversationId);
//     await chatBox.close();
//     super.onClose();
//   }

//   String get parentMessageId => _chatRepository

// }
