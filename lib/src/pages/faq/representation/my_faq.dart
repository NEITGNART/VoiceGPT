import 'package:chatgpt/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../common/constants.dart';
import '../../../../network/admob_service_helper.dart';
import '../data/item.dart';

class MyExpansionPanel extends StatefulWidget {
  const MyExpansionPanel({super.key});

  @override
  _MyExpansionPanelState createState() => _MyExpansionPanelState();
}

class _MyExpansionPanelState extends State<MyExpansionPanel> {
  final BannerAd myBanner = createBannerAds(AdMobService.faqBannerID ?? '');

  final List<Item> _items = [
    Item(headerValue: 'miss_chat'.tr, expandedValue: 'miss_chat_content'.tr),
    Item(
        headerValue: 'common_error'.tr,
        expandedValue: 'common_error_content'.tr),
    Item(headerValue: 'network'.tr, expandedValue: 'network_value'.tr),
    Item(headerValue: 'microphone'.tr, expandedValue: 'microphone_value'.tr),
    Item(headerValue: 'chat'.tr, expandedValue: 'chat_value'.tr),
    Item(headerValue: 'store_chat_title'.tr, expandedValue: 'store_chat'.tr),
    Item(headerValue: 'txt_reuse'.tr, expandedValue: 'txt_reuse_content'.tr),
    Item(headerValue: 'new_feature'.tr, expandedValue: 'tutorial_upcomming'.tr),
    Item(headerValue: 'thanks_title'.tr, expandedValue: 'thanks'.tr),
  ];
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    myBanner.load();
    // _showInterstitialAd();
  }

  @override
  void dispose() {
    myBanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('note'.tr),
          ],
        ),
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionPanelList(
                expandIconColor: Colors.blue,
                // click on header to expand on the icon
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _currentIndex = isExpanded ? -1 : index;
                  });
                },
                children: _items.map((Item item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(item.headerValue, style: kTitle2Style),
                      );
                    },
                    body: ListTile(
                      title: Text(item.expandedValue),
                    ),
                    isExpanded: _currentIndex == _items.indexOf(item),
                  );
                }).toList(),
              ),
            ),
            SvgPicture.asset(
              'assets/setting.svg',
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
        child: AdWidget(ad: myBanner),
      ),
    );
  }
}
