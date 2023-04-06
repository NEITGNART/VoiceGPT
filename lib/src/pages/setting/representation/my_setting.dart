import 'package:chatgpt/src/pages/setting/representation/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/app_sizes.dart';
import '../../../../common/constants.dart';

class MySetting extends StatelessWidget {
  const MySetting({super.key});

  @override
  Widget build(BuildContext context) {
    // get create controller
    final MoreSettingController c = Get.find();

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.blue,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Setting'),
          ],
        ),
      ),
      body: Column(
        children: [
          gapH16,
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: decoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.record_voice_over_outlined,
                        color: Colors.blue),
                    gapW20,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'autoVoice'.tr,
                          style: kTitle2Style.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                // switch
                Obx(
                  () => Switch(
                    value: c.isAutoPlay.value,
                    onChanged: (value) {
                      c.setAutoPlay(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            decoration: decoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.save_as_outlined, color: Colors.blue),
                      gapW20,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'auto_save'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // switch
                Obx(
                  () => Switch(
                    value: c.isAutoSaveChatValue,
                    onChanged: (value) {
                      c.setAutoSaveChat(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                if (!await launchUrl(
                  Uri.parse(
                    'https://www.buymeacoffee.com/zzmanhtien3',
                  ),
                  mode: LaunchMode.externalApplication,
                )) {}
              } catch (e) {}
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              padding: const EdgeInsets.all(10),
              decoration: decoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.blue),
                      gapW20,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'donation'.tr,
                            style: kTitle2Style.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
