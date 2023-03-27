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
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SizedBox(
              child: text.isNotEmpty
                  ? Text(text.replaceFirst('\n\n', ''))
                  : Text('waiting'.tr),
            ),
          ),
          if (text.isNotEmpty) ...{
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
