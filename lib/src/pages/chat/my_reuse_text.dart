import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/common/constants.dart';
import 'package:chatgpt/src/pages/chat/repository/template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyTextReuse extends StatefulWidget {
  const MyTextReuse({super.key});
  @override
  _MyTextReuseState createState() => _MyTextReuseState();
}

class _MyTextReuseState extends State<MyTextReuse> {
  List<Template> templates = [];

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final TemplateController templateController = Get.find();

  final titleKey = GlobalKey<FormFieldState>();
  final messageKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadTemplates() async {
    final box = await Hive.openBox<Template>('templates');
    setState(() {
      templates = box.values.toList();
    });
  }

  void _saveTemplate(Template template) async {
    final box = await Hive.openBox<Template>('templates');
    await box.put(template.id, template);
    setState(() {
      templates = box.values.toList();
    });
  }

  void _showCreateDialog() {
    // clear the text fields
    _titleController.clear();
    _messageController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('create_template'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('title'.tr, style: kTitle2Style),
              gapH12,
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'title_hint'.tr,
                  ),
                ),
              ),
              gapH24,
              Text('content'.tr, style: kTitle2Style),
              gapH12,
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    maxLines: 4,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'content_hint'.tr,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final template = Template(
                  '${DateTime.now().millisecondsSinceEpoch}',
                  _titleController.text,
                  _messageController.text,
                );
                templateController.addTemplate(template);
                Navigator.of(context).pop();
                Get.snackbar('success'.tr, 'success'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void cb(Template template) async {
    {
      _titleController.text = template.title;
      _messageController.text = template.message;
      final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('edit'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('title'.tr, style: kTitle2Style),
                gapH12,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextFormField(
                    key: titleKey,
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                ),
                gapH24,
                Text('content'.tr, style: kTitle2Style),
                gapH12,
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField(
                      key: messageKey,
                      maxLines: 4,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleKey.currentState!.validate() &&
                      messageKey.currentState!.validate()) {
                    final newTemplate = Template(
                      template.id,
                      _titleController.text,
                      _messageController.text,
                    );
                    templateController.updateTemplate(newTemplate);
                    Navigator.of(context).pop(newTemplate);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        Get.snackbar('upd_template'.tr, 'success'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('txt_reuse'.tr),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // show confirmation dialog
                Get.defaultDialog(
                  title: 'del_all_template'.tr,
                  middleText: 'del_all_content'.tr,
                  textConfirm: 'del'.tr,
                  backgroundColor: Colors.white,
                  confirmTextColor: Colors.red.withOpacity(0.5),
                  buttonColor: Colors.transparent,
                  // color of the confirm button
                  onConfirm: () {
                    templateController.deleteAllTemplates();
                    Get.back();
                  },
                  // cancel
                  textCancel: 'cancel'.tr,
                );
              }),
        ],
      ),
      body: MyTemplateList(
          onClick: (Template template) async => {
                cb(template),
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Template {
  final String id;
  final String title;
  final String message;

  Template(this.id, this.title, this.message);
}

class TemplateAdapter extends TypeAdapter<Template> {
  @override
  final int typeId = 0;

  @override
  Template read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final message = reader.readString();
    return Template(id, title, message);
  }

  @override
  void write(BinaryWriter writer, Template obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.message);
  }
}

class MyTemplateList extends StatelessWidget {
  const MyTemplateList({super.key, required this.onClick});
  final Future<Set<void>> Function(Template template) onClick;

  // final Set<void> Function(Template template) onClick;
  // const MyTemplateList({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final TemplateController templateController = Get.find();
    return Obx(
      () {
        if (templateController.templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty.png',
                ),
                Text('no_template'.tr, style: kTitle2Style),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: templateController.templates.length,
          itemBuilder: (context, index) {
            final Template template = templateController.templates[index];
            return Dismissible(
              key: Key(template.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ),
              onDismissed: (direction) {
                templateController.deleteTemplate(template.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${template.title} dismissed'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        templateController.addTemplate(template);
                      },
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade200,
                  child: Text('$index'),
                ),
                title: Text(template.title, style: kHeadlineLabelStyle),
                subtitle: Text(template.message, style: kSubtitleStyle),
                onTap: () async {
                  await onClick(template);
                },
              ),
            );
          },
        );
      },
    );
  }
}
