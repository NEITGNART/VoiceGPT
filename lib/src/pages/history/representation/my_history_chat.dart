import 'package:chatgpt/common/constants.dart';
import 'package:chatgpt/src/pages/history/model/chat_adapter.dart';
import 'package:chatgpt/src/pages/history/representation/body_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHistoryChat extends StatelessWidget {
  const MyHistoryChat({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatHistoryList();
  }
}

class ChatHistoryList extends StatelessWidget {
  ChatHistoryList({super.key});
  final HistoryChatController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('chat_history'.tr),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Get.defaultDialog(
                  title: 'del_all_chat'.tr,
                  middleText: 'del_all_content'.tr,
                  textConfirm: 'del'.tr,
                  backgroundColor: Colors.white,
                  confirmTextColor: Colors.red.withOpacity(0.5),
                  buttonColor: Colors.transparent,
                  // color of the confirm button
                  onConfirm: () {
                    c.deleteAll();
                    Get.back();
                  },
                  // cancel
                  textCancel: 'cancel'.tr,
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (c.chatList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty.png'),
                  Text('empty_chat'.tr, style: kCalloutLabelStyle),
                ],
              ),
            );
          }
          return BodyChat(chatList: c.chatList);
        }),
      ),
    );

    // final chatBox = Hive.box<Chat>('chatBox');

    // return Obx(() {

    //   return ListView.builder(
    //       itemCount: templateController.templates.length,
    //       itemBuilder: (context, index) {
    //         final Template template = templateController.templates[index];
    //         return Dismissible(
    //           key: Key(template.id),
    //           direction: DismissDirection.endToStart,
    //           background: Container(
    //             alignment: Alignment.centerRight,
    //             color: Colors.red,
    //             child: const Padding(
    //               padding: EdgeInsets.only(right: 20),
    //               child: Icon(
    //                 Icons.delete,
    //                 color: Colors.white,
    //               ),
    //             ),
    //           ),
    //           onDismissed: (direction) {
    //             templateController.deleteTemplate(template.id);
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(
    //                 content: Text('${template.title} dismissed'),
    //                 action: SnackBarAction(
    //                   label: 'Undo',
    //                   onPressed: () {
    //                     templateController.addTemplate(template);
    //                   },
    //                 ),
    //               ),
    //             );
    //           },
    //           child: ListTile(
    //             leading: CircleAvatar(
    //               backgroundColor: Colors.blue.shade200,
    //               child: Text('$index'),
    //             ),
    //             title: Text(template.title, style: kHeadlineLabelStyle),
    //             subtitle: Text(template.message, style: kSubtitleStyle),
    //             onTap: () async {
    //               await onClick(template);
    //             },
    //           ),
    //         );
    //       },
    //     )
    // });
  }
}
