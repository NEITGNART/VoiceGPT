// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chatgpt/models/custom_chat_request.dart';
import 'package:chatgpt/models/model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../common/constants.dart';
import '../../models/chat.dart';
import '../../network/api_services.dart';
import '../chat/presentation/audio_waves.dart';
import 'chat/representation/my_chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String messagePrompt = '';
  int tokenValue = 500;
  List<Chat> chatList = [];
  List<Model> modelsList = [];
  late SharedPreferences prefs;
  bool isPlayingSound = false;
  ChatRepository chatRepository = ChatRepositoryImpl();
  final assetsAudioPlayer = AssetsAudioPlayer();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final ScrollController _scrollController = ScrollController();
  late final AudioPlayer player;
  String? _currentLocaleId;
  bool isDebounce = true;
  String conversationId = '';
  String parentMessageId = '';
  int soundPlayingIndex = -1;
  final Map<int, bool> soundPlayingMap = {};
  TextEditingController messageController = TextEditingController();

  late bool isAutoPlaying;

  @override
  void initState() {
    super.initState();
    initPrefs();
    _speech = Get.find<stt.SpeechToText>();

    player = AudioPlayer();
    soundPlayingMap[soundPlayingIndex] = false;
    assetsAudioPlayer.playlistFinished.listen((finished) {
      if (finished) {
        setState(() {
          soundPlayingMap[soundPlayingIndex] = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    assetsAudioPlayer.dispose();
    _scrollController.dispose();
    messageController.dispose();
  }

  void initPrefs() {
    prefs = Get.find<SharedPreferences>();
    isAutoPlaying = prefs.getBool('isAutoPlay') ?? false;
    _currentLocaleId = prefs.getString('localeId');
    // debugPrint("_currentLocaleId: $_currentLocaleId");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/chat-bot.png"),
            ),
            const SizedBox(width: 10),
            Text('botname'.tr),
          ],
        ),
        // actions: [
        //   MySetting(),
        // ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: kLightModeBackgroundColor,
          ),
          child: Column(
            children: [
              // _topChat(),
              Expanded(child: _bodyChat()),
              _formChat(),
            ],
          ),
        ),
      ),
    );
  }

  void saveData(int value) {
    prefs.setInt("token", value);
  }

  int getData() {
    return prefs.getInt("token") ?? 1;
  }

  Widget _bodyChat() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        width: double.infinity,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: chatList.length,
          itemBuilder: (context, index) => _itemChat(
            chat: chatList[index].chat,
            message: chatList[index].msg,
            id: chatList[index].id,
            index: index,
          ),
          controller: _scrollController,
        ),
      ),
    );
  }

  // need to refactor this code. Cuz it's fucking mess
  _itemChat(
      {required int chat,
      required String message,
      String? id,
      required int index}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: chat == 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.length > 10) ...{const Spacer()},
                Flexible(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                        color: chat == 0
                            ? const Color(0xFF5F80F8)
                            : const Color(0xFFEBF5FF),
                        borderRadius: chat == 0
                            ? const BorderRadius.all(Radius.circular(20))
                            : const BorderRadius.all(Radius.circular(20))
                        //  : const BorderRadius.only(
                        //     topLeft: Radius.circular(20),
                        //     topRight: Radius.circular(20),
                        //     bottomRight: Radius.circular(20),
                        //   ),
                        ),
                    child: Text(message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        )),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            AssetImage("assets/images/chat-bot.png"),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                              color: Color(0xFFEBF5FF),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))
                              //  : const BorderRadius.only(
                              //     topLeft: Radius.circular(20),
                              //     topRight: Radius.circular(20),
                              //     bottomRight: Radius.circular(20),
                              //   ),
                              ),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: ChatWidget(isMe: false, text: message)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (message.isNotEmpty && !_isListening) ...{
                  GestureDetector(
                    onTap: () async {
                      // caused this is asynchronous to play sound, sometimes it doesn't play sound
                      await playSound(message, id, index);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      child: soundPlayingMap[index] == false
                          ? const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.pause,
                              color: Colors.white,
                            ),
                    ),
                  )
                } else ...{
                  const SizedBox()
                },
              ],
            ),
    );
  }

  Future<void> playSound(String message, String? id, int index) async {
    if (Platform.isIOS || true) {
      try {
        setState(() {
          if (isPlayingSound == true &&
              index != -1 &&
              index != soundPlayingIndex) {
            soundPlayingMap[soundPlayingIndex] = false;
            isPlayingSound = true;
          } else {
            isPlayingSound = !isPlayingSound;
          }
          // flip the playing
          soundPlayingMap[index] = isPlayingSound;
          // When the audio is finised playing, reset the index. We know the index to pause icon
          soundPlayingIndex = index;
        });

        if (isPlayingSound == false) {
          assetsAudioPlayer.pause();
          return;
        }

        final Directory tempDir = await getTemporaryDirectory();
        // save audio file to temporary directory using tempDir
        final String path = "${tempDir.path}/synthesized_audio_$id.mp3";
        // check if file exists
        final File file = File(path);
        file.exists().then((value) async {
          if (value) {
            await assetsAudioPlayer.open(
              Audio.file(path),
              // pause
            );
          } else {
            final audioBytes = await synthesizeSpeech(message);
            await file.writeAsBytes(audioBytes);
            await assetsAudioPlayer.open(
              Audio.file(path),
            );
          }
        });
      } catch (e) {
        //
      }
      // } else {
      //   if (isDebounce == true) {
      //     isDebounce = false;
      //     AudioCache cache = AudioCache();
      //     final audioBytes = await synthesizeSpeech(message);
      //     final byteSouce = BytesSource(audioBytes);
      //     // save audio file to temporary directory using tempDir
      //     final Directory tempDir = await getTemporaryDirectory();
      //     final String path = "${tempDir.path}/synthesized_audio_$id.mp3";

      //     await player.play(byteSouce);
      //     Timer(
      //       const Duration(seconds: 3),
      //       () {
      //         isDebounce = true;
      //       },
      //     );
      //   }
      // }
    }
  }

  Widget _formChat() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AbsorbPointer(
                  absorbing: _isListening,
                  child: TextField(
                    buildCounter: (BuildContext context,
                            {required int currentLength,
                            required bool isFocused,
                            required int? maxLength}) =>
                        null,
                    // display scroll on keyboard on the right
                    autocorrect: true,
                    maxLength: textLimit,
                    onChanged: (value) {
                      setState(() {
                        if (value.length == textLimit) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 500),
                              content: Text(
                                'longMessage'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      });
                    },
                    // croll if the textfield is overflow
                    maxLines: 4,
                    minLines: 1,
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: !_isListening ? 'hint'.tr : '',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      prefixIcon: _isListening && messageController.text.isEmpty
                          ? Container(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.1),
                              child: MyAudioWave(context: context),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                      contentPadding: const EdgeInsets.all(15),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              //  messageController.text.isNotEmpty

              if (!_isListening && messageController.text.isEmpty) ...{
                if (soundPlayingMap[soundPlayingIndex] == false)
                  InkWell(
                    onTap: () {
                      _listen();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.black,
                      ),
                    ),
                  )
              },
              // const Expanded(child: FlowMenu()),
              // adding animation to the send button

              if (messageController.text.isNotEmpty || _isListening)
                InkWell(
                  child: Column(
                    children: [
                      if (messageController.text.isNotEmpty ||
                          _isListening) ...{
                        InkWell(
                          onTap: () {
                            _speech.cancel();
                            messageController.clear();
                            setState(() {
                              _isListening = false;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 25),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.black,
                              weight: 5,
                            ),
                          ),
                        )
                      },
                      InkWell(
                        onTap: (() async {
                          messagePrompt = messageController.text.toString();
                          _speech.cancel();
                          _isListening = false;
                          if (messagePrompt.isEmpty) {
                            return;
                          }
                          chatList.add(Chat(
                              msg: messagePrompt,
                              chat: 0,
                              // timestemp for file
                              id: '${DateTime.now().millisecondsSinceEpoch}'));
                          chatList.add(Chat(
                              msg: '',
                              chat: 1,
                              id: '${DateTime.now().millisecondsSinceEpoch}'));

                          int n = chatList.length;

                          soundPlayingMap[n - 1] = false;
                          soundPlayingMap[n - 2] = false;

                          setState(() {
                            messageController.clear();
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          });

                          // var submitGetChatsForm2 = await submitGetChatsForm(
                          //   context: context,
                          //   prompt: messagePrompt,
                          //   tokenValue: tokenValue,
                          // );

                          // set to chatList item at index n-1
                          try {
                            final reponse = await chatRepository.send(
                                context: context,
                                chat: CustomChatRequest(
                                    message: messagePrompt,
                                    conversationId: conversationId,
                                    parentMessageId: parentMessageId));

                            conversationId = reponse?.conversationId ?? "";
                            parentMessageId = reponse?.parentMessageId ?? "";

                            chatList[n - 1] = Chat(
                                msg: reponse?.text ??
                                    "Sorry, service is temporary unavailable",
                                chat: 1,
                                id: parentMessageId);

                            if (isAutoPlaying == true) {
                              try {
                                await playSound(
                                    reponse?.text ??
                                        "Sorry, service is temporary unavailable",
                                    parentMessageId,
                                    n - 1);
                              } catch (e) {
                                rethrow;
                              }
                            }
                          } catch (e) {
                            chatList[n - 1] = Chat(
                                msg: "Sorry, service is temporary unavailable",
                                chat: 1,
                                id: parentMessageId);
                          }
                          setState(() {
                            messageController.clear();
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          });
                        }),
                        child: Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _currentLocaleId,
          onResult: (val) => setState(
            () {
              messageController.text = val.recognizedWords;
              messageController.selection = TextSelection.fromPosition(
                  TextPosition(offset: messageController.text.length));
            },
          ),
        );
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }
}


// class FlowMenu extends StatefulWidget {
//   const FlowMenu({super.key});

//   @override
//   State<FlowMenu> createState() => _FlowMenuState();
// }

// class _FlowMenuState extends State<FlowMenu>
//     with SingleTickerProviderStateMixin {
//   late AnimationController menuAnimation;
//   IconData lastTapped = Icons.notifications;
//   final List<IconData> menuItems = <IconData>[
//     Icons.home,
//     Icons.new_releases,
//     Icons.notifications,
//     Icons.settings,
//     Icons.menu,
//   ];

//   void _updateMenu(IconData icon) {
//     if (icon != Icons.menu) {
//       setState(() => lastTapped = icon);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     menuAnimation = AnimationController(
//       duration: const Duration(milliseconds: 250),
//       vsync: this,
//     );
//   }

//   Widget flowMenuItem(IconData icon) {
//     final double buttonDiameter =
//         MediaQuery.of(context).size.width / menuItems.length;
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: RawMaterialButton(
//         fillColor: lastTapped == icon ? Colors.amber[700] : Colors.blue,
//         splashColor: Colors.amber[100],
//         shape: const CircleBorder(),
//         constraints: BoxConstraints.tight(Size(buttonDiameter, buttonDiameter)),
//         onPressed: () {
//           _updateMenu(icon);
//           menuAnimation.status == AnimationStatus.completed
//               ? menuAnimation.reverse()
//               : menuAnimation.forward();
//         },
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 45.0,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Flow(
//       delegate: FlowMenuDelegate(menuAnimation: menuAnimation),
//       children:
//           menuItems.map<Widget>((IconData icon) => flowMenuItem(icon)).toList(),
//     );
//   }
// }

// class FlowMenuDelegate extends FlowDelegate {
//   FlowMenuDelegate({required this.menuAnimation})
//       : super(repaint: menuAnimation);

//   final Animation<double> menuAnimation;

//   @override
//   bool shouldRepaint(FlowMenuDelegate oldDelegate) {
//     return menuAnimation != oldDelegate.menuAnimation;
//   }

//   @override
//   void paintChildren(FlowPaintingContext context) {
//     double dx = 0.0;
//     for (int i = 0; i < context.childCount; ++i) {
//       dx = context.getChildSize(i)!.width * i;
//       context.paintChild(
//         i,
//         transform: Matrix4.translationValues(
//           dx * menuAnimation.value,
//           0,
//           0,
//         ),
//       );
//     }
//   }
// }

// Route _createRoute() {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) =>
//         const SettingPage(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       const begin = Offset(0.0, 1.0);
//       const end = Offset.zero;
//       const curve = Curves.ease;

//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
