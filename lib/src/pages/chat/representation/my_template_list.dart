import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/template.dart';

class TemplateList extends StatelessWidget {
  final TemplateController templateController = Get.find<TemplateController>();
  final TextEditingController messageController;

  TemplateList({Key? key, required this.messageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (templateController.templates.isEmpty) {
        return Center(
          child: Text('no_template'.tr),
        );
      }
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templateController.templates.length,
        itemBuilder: (context, i) {
          return Container(
            margin: const EdgeInsets.all(5),
            child: InputChip(
                backgroundColor: Colors.blue.shade300,
                label: Text(templateController.templates[i].title),
                onPressed: () {
                  messageController.text +=
                      templateController.templates[i].message;
                  // point to the end of the text
                  messageController.selection = TextSelection.fromPosition(
                      TextPosition(offset: messageController.text.length));
                }),
          );
        },
      );
    });
  }
}
