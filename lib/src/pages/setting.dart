// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late stt.SpeechToText _speech;
  late SharedPreferences sp;
  @override
  void initState() {
    super.initState();
    _speech = Get.find<stt.SpeechToText>();
    sp = Get.find<SharedPreferences>();
  }

  @override
  Widget build(BuildContext context) {
    final sp = Get.find<SharedPreferences>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'setting'.tr,
              // align left
            ),
          ],
        ),
      ),
      body: Container(
        // background
        child: Column(
          children: [
            gapH20,
            GestureDetector(
              onTap: () {
                Get.to(const MyLanguage());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'language'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'currentLanguage'.tr,
                              style: kCardSubtitleStyle.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over_outlined),
                      gapW20,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'autoVoice'.tr,
                            style: kTitle2Style.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  // switch
                  Switch(
                    value: sp.getBool('isAutoPlay') ?? true,
                    onChanged: (value) {
                      sp.setBool('isAutoPlay', value);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const MyVoiceLanguge());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.record_voice_over),
                        gapW20,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'voice'.tr,
                              style: kTitle2Style.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              sp.getString('voiceRecord') ?? 'English',
                              style: kCardSubtitleStyle.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios)
                  ],
                ),
              ),
            ),
            // change language
            // ElevatedButton(
            //   onPressed: () {},
            //   child: const Text('Change Language'),
            // ),

            // InkWell(
            //   onTap: () {
            //     Get.updateLocale(const Locale('vi', 'VN'));
            //   },
            //   child: Row(children: [
            //     Text('language'.tr),
            //   ]),
            // ),
            Expanded(
                child: Center(
              child: SvgPicture.asset(
                'assets/setting.svg',
                fit: BoxFit.cover,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class Language {
  final String name;
  final String iconUrl;
  final String code;
  final String countryCode;

  Language(
    this.name,
    this.iconUrl,
    this.code,
    this.countryCode,
  );
}

class MyLanguage extends StatelessWidget {
  const MyLanguage({super.key});

  List<Language> get languages => [
        Language(
          'Tiếng Việt',
          'assets/vn-flag.svg',
          'vi',
          'VN',
        ),
        Language(
          'English',
          'assets/united-kingdom-flag.svg',
          'en',
          'US',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'language'.tr,
              // align left
            ),
          ],
        ),
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: SvgPicture.asset(
                      languages[index].iconUrl,
                      width: 30,
                      height: 30,
                    ),
                    title: Text(languages[index].name),
                    onTap: () {
                      Get.updateLocale(Locale(
                          languages[index].code, languages[index].countryCode));
                      prefs.setString(
                        'languageCode',
                        languages[index].code,
                      );
                      prefs.setString(
                        'countryCode',
                        languages[index].countryCode,
                      );
                    },
                  );
                },
                itemCount: 2),
          ),
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/setting.svg',
              ),
            ),
          ),
        ],
      )),
    );
  }
}

// class MyVoiceLanguge extends StatelessWidget {
//   const MyVoiceLanguge({super.key});

//   @override
//   Widget build(BuildContext context) {
//     SharedPreferences prefs = Get.find<SharedPreferences>();
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Text(
//               'language'.tr,
//               // align left
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               // showSearch(
//               //   context: context,
//               //   delegate: Search(),
//               //   );
//             },
//           ),
//         ],
//       ),
//       body: Container(
//           child: FutureBuilder(
//         builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//           if (snapshot.hasData) {
//             return ListView.builder(
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(snapshot.data[index].name),
//                   onTap: () {
//                     prefs.setString(
//                       'localeId',
//                       snapshot.data[index].localeId,
//                     );
//                     prefs.setString(
//                       'voiceRecord',
//                       snapshot.data[index].name,
//                     );
//                     debugPrint('localeId: ${snapshot.data[index].localeId}');
//                   },
//                 );
//               },
//               itemCount: snapshot.data.length,
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//         future: getLocales(),
//       )),
//     );
//   }

//   Future<List<LocaleName>> getLocales() async {
//     final speech = Get.find<stt.SpeechToText>();
//     await speech.initialize();
//     return speech.locales();
//   }
// }

class MyVoiceLanguge extends StatefulWidget {
  const MyVoiceLanguge({Key? key}) : super(key: key);

  @override
  _MyVoiceLangugeState createState() => _MyVoiceLangugeState();
}

class _MyVoiceLangugeState extends State<MyVoiceLanguge> {
  late Future<List<LocaleName>> _localesFuture;
  List<LocaleName> _locales = [];

  @override
  void initState() {
    super.initState();
    _localesFuture = getLocales();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'language'.tr,
              // align left
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: LocaleSearchDelegate(_locales),
              );
              if (result != null) {
                prefs.setString('localeId', result.localeId);
                prefs.setString('voiceRecord', result.name);
                debugPrint('localeId: ${result.localeId}');
              }
            },
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder<List<LocaleName>>(
          future: _localesFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<LocaleName>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              _locales = snapshot.data ?? [];
              return ListView.builder(
                itemCount: _locales.length,
                itemBuilder: (BuildContext context, int index) {
                  final locale = _locales[index];
                  return ListTile(
                    title: Text(locale.name),
                    onTap: () {
                      final snackBar = SnackBar(
                        content: Text('changeVoiceSuccess'.tr),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      prefs.setString('localeId', locale.localeId);
                      prefs.setString('voiceRecord', locale.name);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<LocaleName>> getLocales() async {
    final speech = Get.find<stt.SpeechToText>();
    await speech.initialize();
    return speech.locales();
  }
}

class LocaleSearchDelegate extends SearchDelegate<LocaleName> {
  final List<LocaleName> locales;

  LocaleSearchDelegate(this.locales);

  @override
  String get searchFieldLabel => 'Search languages';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    SharedPreferences prefs = Get.find<SharedPreferences>();
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Default locale
        String id = prefs.getString('localeId') ?? 'en_US';
        String name = prefs.getString('voiceRecord') ?? 'English';
        close(context, LocaleName(id, name));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = locales
        .where(
            (locale) => locale.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final locale = results[index];
        return ListTile(
          title: Text(locale.name),
          subtitle: Text(locale.localeId),
          onTap: () {
            final snackBar = SnackBar(
              content: Text('changeVoiceSuccess'.tr),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // not see result
            close(context, locale);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = locales
        .where(
            (locale) => locale.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final locale = results[index];
        return ListTile(
          title: Text(locale.name),
          subtitle: Text(locale.localeId),
          onTap: () {
            close(context, locale);
          },
        );
      },
    );
  }
}
