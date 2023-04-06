import 'package:flutter/material.dart';

import '../../chat/representation/my_chat_message.dart';

class ChatItem extends StatelessWidget {
  final int chat;
  final String message;
  final String? id;
  final int index;

  const ChatItem({
    Key? key,
    required this.chat,
    required this.message,
    this.id,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: chat == 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.length > 10) ...{const Spacer()},
                Flexible(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                        color: chat == 0
                            ? const Color(0xFF5F80F8)
                            : const Color(0xFFEBF5FF),
                        borderRadius: chat == 0
                            ? const BorderRadius.all(Radius.circular(20))
                            : const BorderRadius.all(Radius.circular(20))),
                    child: SelectableText(message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            AssetImage("assets/images/chat-bot.png"),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                              color: Color(0xFFEBF5FF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: ChatWidget(isMe: false, text: message)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
