// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// Future<bool> requestStoragePermission() async {
//   final status = await Permission.storage.request();
//   return status == PermissionStatus.granted;
// }

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
        // decoration: const BoxDecoration(
        //   borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(45), topRight: Radius.circular(45)),
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/chat-background.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
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
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment:
                  chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                chat == 1
                    ? const CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            AssetImage("assets/images/chat-bot.png"),
                      )
                    : Container(),
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
                    child: chat == 0
                        ? message.length < 5
                            ? ChatWidget(text: message, isMe: true)
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: ChatWidget(isMe: true, text: message))
                        : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ChatWidget(isMe: false, text: message)),
                  ),
                ),
              ],
            ),
          ),
          if (chat == 1 && message.isNotEmpty && !_isListening) ...{
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
            Container()
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
                                chatList.add(Chat(
                                    msg:
                                        "Sorry, service is temporary unavailable",
                                    chat: 1,
                                    id: parentMessageId));
                                int m = chatList.length;
                                chatList[m - 1] = Chat(
                                    msg:
                                        "Sorry, the voice service is temporary unavailable",
                                    chat: 1,
                                    id: parentMessageId);
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
          // Column(
          //   children: [
          //     AvatarGlow(
          //         animate: _isListening,
          //         glowColor: Colors.green,
          //         endRadius: 60.0,
          //         duration: const Duration(milliseconds: 2000),
          //         repeatPauseDuration: const Duration(milliseconds: 500),
          //         repeat: true,
          //         child: InkWell(
          //           onTap: () {
          //             _listen();
          //           },
          //           child: Container(
          //             width: 80,
          //             height: MediaQuery.of(context).size.height,
          //             decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: _isListening
          //                   ? Colors.green
          //                   : Theme.of(context).primaryColor,
          //             ),
          //             child: Icon(_isListening ? Icons.mic : Icons.mic_none,
          //                 size: 50, color: Colors.white),
          //           ),
          //         )
          //         // child: FloatingActionButton(
          //         //   // increase the size of the button
          //         //   backgroundColor:
          //         //       _isListening ? Colors.green : Theme.of(context).primaryColor,
          //         //   onPressed: _listen,
          //         //   child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 80),
          //         // ),
          //         ),
          //     Text(
          //       _isListening ? 'Listening' : 'Press to Speak',
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 12,
          //       ),
          //     ),
          //     const SizedBox(
          //       height: 20,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  // GestureDetector MySetting() {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(context, _createRoute());

  //       // showModalBottomSheet<void>(
  //       //   context: context,
  //       //   backgroundColor: Colors.transparent,
  //       //   builder: (BuildContext context) {
  //       //     return StatefulBuilder(
  //       //         builder: (BuildContext context, StateSetter state) {
  //       //       return Container(
  //       //         height: 400,
  //       //         decoration: const BoxDecoration(
  //       //             color: Colors.white,
  //       //             borderRadius: BorderRadius.only(
  //       //               topLeft: Radius.circular(20),
  //       //               topRight: Radius.circular(20),
  //       //             )),
  //       //         child: Column(
  //       //           mainAxisAlignment: MainAxisAlignment.start,
  //       //           mainAxisSize: MainAxisSize.min,
  //       //           children: <Widget>[
  //       //             const Padding(
  //       //               padding: EdgeInsets.symmetric(vertical: 15.0),
  //       //               child: Text(
  //       //                 'Settings',
  //       //                 style: TextStyle(
  //       //                   color: Color(0xFFF75555),
  //       //                   fontWeight: FontWeight.bold,
  //       //                 ),
  //       //               ),
  //       //             ),
  //       //             Divider(
  //       //               color: Colors.grey.shade700,
  //       //             ),
  //       //             Padding(
  //       //               padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
  //       //               child: DropdownButtonFormField(
  //       //                 items: models,
  //       //                 borderRadius: const BorderRadius.only(),
  //       //                 focusColor: Colors.amber,
  //       //                 onChanged: (String? s) {},
  //       //                 decoration:
  //       //                     const InputDecoration(hintText: "Select Model"),
  //       //               ),
  //       //             ),
  //       //             const Padding(
  //       //               padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
  //       //               child: Align(
  //       //                   alignment: Alignment.topLeft, child: Text("Token")),
  //       //             ),
  //       //             Slider(
  //       //               min: 0,
  //       //               max: 1000,
  //       //               activeColor: const Color(0xFFE58500),
  //       //               inactiveColor: const Color.fromARGB(255, 230, 173, 92),
  //       //               value: tokenValue.toDouble(),
  //       //               onChanged: (value) {
  //       //                 state(() {
  //       //                   tokenValue = value.round();
  //       //                 });
  //       //               },
  //       //             ),
  //       //             Padding(
  //       //               padding: const EdgeInsets.symmetric(vertical: 10.0),
  //       //               child: Row(
  //       //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       //                 children: [
  //       //                   InkWell(
  //       //                     onTap: () {
  //       //                       Navigator.of(context).pop(false);
  //       //                     },
  //       //                     child: Container(
  //       //                       width: MediaQuery.of(context).size.width / 2.2,
  //       //                       decoration: BoxDecoration(
  //       //                         color: Colors.grey.shade200,
  //       //                         borderRadius: BorderRadius.circular(40),
  //       //                       ),
  //       //                       padding: const EdgeInsets.symmetric(
  //       //                           vertical: 15, horizontal: 20),
  //       //                       child: const Center(
  //       //                         child: Text(
  //       //                           'Cancel',
  //       //                           style: TextStyle(
  //       //                             color: Colors.black,
  //       //                             fontWeight: FontWeight.bold,
  //       //                           ),
  //       //                         ),
  //       //                       ),
  //       //                     ),
  //       //                   ),
  //       //                   InkWell(
  //       //                     onTap: () {
  //       //                       saveData(tokenValue);
  //       //                       Navigator.of(context).pop(false);
  //       //                     },
  //       //                     child: Container(
  //       //                       width: MediaQuery.of(context).size.width / 2.2,
  //       //                       decoration: BoxDecoration(
  //       //                         color: const Color(0xFFE58500),
  //       //                         borderRadius: BorderRadius.circular(40),
  //       //                       ),
  //       //                       padding: const EdgeInsets.symmetric(
  //       //                           vertical: 15, horizontal: 20),
  //       //                       child: const Center(
  //       //                         child: Text(
  //       //                           'Save',
  //       //                           style: TextStyle(
  //       //                             color: Colors.black,
  //       //                             fontWeight: FontWeight.bold,
  //       //                           ),
  //       //                         ),
  //       //                       ),
  //       //                     ),
  //       //                   )
  //       //                 ],
  //       //               ),
  //       //             ),
  //       //           ],
  //       //         ),
  //       //       );
  //       //     });
  //       //   },
  //       // );
  //     },
  //     child: const Icon(
  //       Icons.more_vert_rounded,
  //       size: 25,
  //       color: Colors.white,
  //     ),
  //   );
  // }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
          // onStatus: (val) => print('onStatus: $val'),
          // onError: (val) => print('onError: $val'),
          );
      if (available) {
        // var locales = await _speech.locales();
        // put locales to Setting page

        // Get.to(() => SettingPage(locales: locales));

        // // print('locales': locales);
        // logger.i('locales: $locales');
        // // locale vietnamese

        // for (var element in locales) {
        //   // logg element
        //   logger.i('element: ${element.name}');
        // }
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

class ChatWidget extends StatelessWidget {
  final bool isMe;
  final String text;

  const ChatWidget({
    Key? key,
    required this.isMe,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: isMe == true ? Colors.white : Colors.black,
        fontSize: 16,
      ),
      child: SizedBox(
        child: isMe
            ? Text(
                text.replaceFirst('\n\n', ''),
              )
            : text.isNotEmpty
                ? AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        text.replaceFirst('\n\n', ''),
                      ),
                    ],
                    repeatForever: false,
                    totalRepeatCount: 1,
                  )
                : Text('waiting'.tr),
      ),
    );
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
