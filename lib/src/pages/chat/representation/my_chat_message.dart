import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatWidget extends StatelessWidget {
  final bool isMe;
  final String text;

  const ChatWidget({
    Key? key,
    required this.isMe,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: isMe == true ? Colors.white : Colors.black,
        fontSize: 16,
      ),
      child: Row(
        // mainAxisAlignment: (text == 'Waiting for response...' ||
        //         text == 'Tin nhắn đang được tải về...' ||
        //         isMe)
        //     ? MainAxisAlignment.start
        //     : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SizedBox(
              child: isMe
                  ? Text(
                      text.replaceFirst('\n\n', ''),
                    )
                  : text.isNotEmpty
                      ? AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              text.replaceFirst('\n\n', ''),
                            ),
                          ],
                          repeatForever: false,
                          totalRepeatCount: 1,
                        )
                      : Text('waiting'.tr),
            ),
          ),
          // clipboard
          if (!isMe) ...{
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: const Icon(Icons.copy),
                  onTap: () {
                    // FlutterClipboard
                    FlutterClipboard.copy(text).then((value) => {
                          Get.snackbar(
                            'copied'.tr,
                            text,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.white,
                            colorText: Colors.black,
                            margin: const EdgeInsets.all(10),
                            borderRadius: 10,
                            duration: const Duration(seconds: 2),
                          )
                        });
                  },
                )
              ],
            )
          }
        ],
      ),
    );
  }
}
