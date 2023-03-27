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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Enter message',
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
                _saveTemplate(template);
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Template>('templates');
    return Scaffold(
      appBar: AppBar(
        title: Text('txt_reuse'.tr),
        actions: [
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                // delete all templates
                box.deleteFromDisk();
              }),
        ],
      ),
      body: Builder(
        builder: (context) {
          final templates = box.values.toList();
          return templates.isEmpty
              ? const Center(child: Text('No templates yet'))
              : ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
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
                        box.delete(template.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${template.title} dismissed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  box.put(template.id, template);
                                });
                              },
                            ),
                          ),
                        );
                        setState(() {}); // Rebuild the ListView
                      },
                      child: ListTile(
                        title: Text(template.title),
                        subtitle: Text(template.message),
                        onTap: () async {
                          _titleController.text = template.title;
                          _messageController.text = template.message;
                          final result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Edit Template'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      key: titleKey,
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        hintText: 'Title',
                                      ),
                                    ),
                                    TextFormField(
                                      key: messageKey,
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: 'Message',
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
                                        box.put(template.id, newTemplate);
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
                            Get.snackbar('Template updated', 'Template updated',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 1));
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text('Template updated'),
                            //     duration: Duration(seconds: 1),
                            //   ),
                            // );
                          }
                        },
                      ),
                    );
                  },
                );
        },
      ),
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
