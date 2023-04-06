import 'package:flutter/material.dart';

import '../../../../models/chat.dart';
import 'item_chart.dart';

class BodyChat extends StatefulWidget {
  final List<Chat> chatList;

  const BodyChat({
    Key? key,
    required this.chatList,
  }) : super(key: key);

  @override
  State<BodyChat> createState() => _BodyChatState();
}

class _BodyChatState extends State<BodyChat> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        width: double.infinity,
        child: ListView.builder(
          reverse: true,
          scrollDirection: Axis.vertical,
          itemCount: widget.chatList.length,
          itemBuilder: (context, index) {
            final reversedIndex = widget.chatList.length - index - 1;
            return ChatItem(
              chat: widget.chatList[reversedIndex].chat,
              message: widget.chatList[reversedIndex].msg,
              id: widget.chatList[reversedIndex].id,
              index: reversedIndex,
            );
          },
        ),
      ),
    );
  }
}
