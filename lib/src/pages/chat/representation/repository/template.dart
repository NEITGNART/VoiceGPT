import 'package:chatgpt/src/pages/chat/my_reuse_text.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HiveBoxes {
  static final HiveBoxes _instance = HiveBoxes._internal();

  factory HiveBoxes() {
    return _instance;
  }
  HiveBoxes._internal();
  Future<Box<T>> openBox<T>(String name) async {
    return await Hive.openBox<T>(name);
  }
}

class TemplateController extends GetxController {
  late Box<Template> templateBox;
  RxList<Template> templates = RxList<Template>();

  @override
  void onInit() async {
    templateBox = await HiveBoxes().openBox<Template>('templates');
    templates.value = templateBox.values.toList();
    super.onInit();
  }

  void addTemplate(Template template) {
    // add with template.id
    templateBox.put(template.id, template);
    templates.add(template);
  }

  void deleteTemplate(String id) {
    final index = templates.indexWhere((template) => template.id == id);
    if (index >= 0) {
      templateBox.delete(id);
      templates.removeAt(index);
    }
  }
}
