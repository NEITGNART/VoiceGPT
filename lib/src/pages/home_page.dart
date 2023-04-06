import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/common/constants.dart';
import 'package:chatgpt/network/admob_service_helper.dart';
import 'package:chatgpt/src/pages/chat_page.dart';
import 'package:chatgpt/src/pages/setting.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/my_admob.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static AdRequest request = const AdRequest(nonPersonalizedAds: true);

  InterstitialAd? _interstitialAd;
  bool _isButtonEnabled = true;
  bool wantSmallNativeAd = false;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId ?? '',
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('$ad loaded');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error.');
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) {
      log('Warning: attempt to show interstitial before loaded.');
      // logger.e('Warning: attempt to show interstitial before loaded.');
      Get.offAll(
        () => const ChatPage(),
      );
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          log('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        Get.off(
          () => const ChatPage(),
        );
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        Get.offAll(
          () => const ChatPage(),
        );
      },
    );
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    _createInterstitialAd();
    // _showInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              child: SvgPicture.asset(
                'assets/setting.svg',
              ),
            ),
            gapW20,
            Expanded(
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    'welcome'.tr,
                  ),
                ],
                repeatForever: true,
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xffadf7f2).withOpacity(0.5),
                  const Color(0xff15aaff).withOpacity(1),
                  // Color(0xffFED8F7),
                  // Color(0xffC4DDFE),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buttonWidget(
                  'nav_chat'.tr,
                  () async {
                    if (!_isButtonEnabled) return;
                    _isButtonEnabled = false;
                    // wait 1 second
                    Get.snackbar(
                      'nav_chat'.tr,
                      'go_chat'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.white,
                      colorText: Colors.black,
                      margin: const EdgeInsets.all(20),
                      borderRadius: 20,
                      duration: const Duration(milliseconds: 1000),
                    );
                    await Future.delayed(const Duration(milliseconds: 2000));
                    await _showInterstitialAd();
                  },
                  SvgPicture.asset('assets/chat.svg', height: 40),
                ),
                buttonWidget(
                  'setting'.tr,
                  () {
                    Get.off(
                      () => const SettingPage(),
                    );
                  },
                  SvgPicture.asset('assets/settings.svg', height: 40),
                ),
                buttonWidget(
                  'suggest'.tr,
                  () {
                    // _showInterstitialAd();
                    _launchUrl(
                      Uri.parse(
                        'https://forms.gle/LXmyxawkPM6az8Dq5',
                      ),
                    );
                  },
                  SvgPicture.asset('assets/contact.svg', height: 40),
                ),
                SvgPicture.asset(
                  'assets/hi.svg',
                  height: 300,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MyBannerAd(
        adUnitId: AdMobService.mainPageBannerId ?? '',
      ),
    );
  }

  Widget buttonWidget(String text, VoidCallback onTap, Widget icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 10,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon,
            gapW20,
            Expanded(
              child: Text(
                text,
                style: kTitle1Style.copyWith(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) throw 'Could not launch $url';
  }
}

// class ChatMainPage extends StatefulWidget {
//   const ChatMainPage({super.key});
//   @override
//   State<ChatMainPage> createState() => _ChatMainPageState();
// }

// class _ChatMainPageState extends State<ChatMainPage> {
//   int _selectedIndex = 0;

//   static final List<Widget> _widgetOptions = <Widget>[
//     const HomePage(),
//     const MyHistoryChat(),
//     const SettingPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 20,
//               color: Colors.black.withOpacity(.1),
//             )
//           ],
//         ),
//         child: SafeArea(
//             child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
//           child: GNav(
//             rippleColor: Colors.grey[300]!,
//             hoverColor: Colors.grey[100]!,
//             gap: 8,
//             activeColor: Colors.blue,
//             iconSize: 24,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             duration: const Duration(milliseconds: 400),
//             tabBackgroundColor: Colors.blue.shade100,
//             color: Colors.blue.shade400,
//             tabs: const [
//               GButton(
//                 icon: Icons.home,
//                 text: 'Home',
//               ),
//               GButton(
//                 icon: Icons.history,
//                 text: 'History',
//               ),
//               GButton(
//                 icon: Icons.settings,
//                 text: 'Settings',
//               ),
//             ],
//             selectedIndex: _selectedIndex,
//             onTabChange: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//           ),
//         )),
//       ),
//     );
//   }
// }
