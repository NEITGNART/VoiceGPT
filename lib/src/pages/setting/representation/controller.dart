// ignore_for_file: public_member_api_docs, sort_constructors_first
// create get controller

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MoreSetting {
  final bool isAutoPlay;
  final bool isAutoSaveChat;
  MoreSetting({
    required this.isAutoPlay,
    required this.isAutoSaveChat,
  });
}

class MoreSettingAdapter extends TypeAdapter<MoreSetting> {
  @override
  final typeId = 1;

  @override
  MoreSetting read(BinaryReader reader) {
    final isAutoPlay = reader.readBool();
    final isAutoSave = reader.readBool();
    return MoreSetting(
      isAutoPlay: isAutoPlay,
      isAutoSaveChat: isAutoSave,
    );
  }

  @override
  void write(BinaryWriter writer, MoreSetting obj) {
    writer.writeBool(obj.isAutoPlay);
    writer.writeBool(obj.isAutoSaveChat);
  }
}

class HiveBoxes {
  Future<Box<T>> openBox<T>(String name) async {
    await Hive.initFlutter();
    Hive.registerAdapter(MoreSettingAdapter());
    return Hive.openBox<T>(name);
  }
}

class MoreSettingController extends GetxController {
  var isAutoPlay = false.obs;
  var isAutoSaveChat = true.obs;
  late Box<MoreSetting> moreSettingBox;

  @override
  void onInit() async {
    moreSettingBox = await HiveBoxes().openBox<MoreSetting>('moreSetting');
    final moreSetting = moreSettingBox.get('moreSetting',
        defaultValue: MoreSetting(isAutoPlay: false, isAutoSaveChat: true));
    isAutoPlay.value = moreSetting?.isAutoPlay ?? false;
    isAutoPlay.value = moreSetting?.isAutoSaveChat ?? true;
    super.onInit();
  }

  void toggleAutoPlay() {
    isAutoPlay.value = !isAutoPlay.value;
    moreSettingBox.put(
      'moreSetting',
      MoreSetting(
        isAutoPlay: isAutoPlay.value,
        isAutoSaveChat: true,
      ),
    );
  }

  void setAutoPlay(bool value) {
    isAutoPlay.value = value;
    moreSettingBox.put(
      'moreSetting',
      MoreSetting(
        isAutoPlay: isAutoPlay.value,
        isAutoSaveChat: true,
      ),
    );
  }

  void setAutoSaveChat(bool value) {
    isAutoSaveChat.value = value;
    moreSettingBox.put(
      'moreSetting',
      MoreSetting(
        isAutoPlay: false,
        isAutoSaveChat: isAutoSaveChat.value,
      ),
    );
  }

  bool get isAutoPlayValue => isAutoPlay.value;
  bool get isAutoSaveChatValue => isAutoSaveChat.value;
}
