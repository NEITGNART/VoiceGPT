import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatgpt/models/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models/chat.dart';
import '../../network/api_services.dart';

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

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    getModels();
    initPrefs();
    _speech = stt.SpeechToText();
  }

  final PanelController _pc = PanelController();

  void getModels() async {
    modelsList = await submitGetModelsForm(context: context);
  }

  List<DropdownMenuItem<String>> get models {
    List<DropdownMenuItem<String>> menuItems =
        List.generate(modelsList.length, (i) {
      return DropdownMenuItem(
        value: modelsList[i].id,
        child: Text(modelsList[i].id),
      );
    });
    return menuItems;
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    tokenValue = prefs.getInt("token") ?? 500;
  }

  Widget _floatingPanel() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ]),
      margin: const EdgeInsets.all(24.0),
      child: const Center(
        child: Text("This is the SlidingUpPanel when open"),
      ),
    );
  }

  TextEditingController mesageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: _pc,
        backdropEnabled: true,
        maxHeight: MediaQuery.of(context).size.height * 0.25,
        minHeight: 0,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        padding: const EdgeInsets.all(15),
        panel: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _pc.close();
              },
              child: const Row(
                children: [
                  Icon(Icons.voice_chat),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Play with voice',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Row(
              children: [
                Icon(Icons.copy),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Copy message',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Row(
              children: [
                Icon(Icons.share),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Share answer',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(100, 168, 20, 236),
                  Color(0xFFfdc830),
                ],
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    _topChat(),
                    _bodyChat(),
                    const SizedBox(
                      height: 85,
                    ),
                  ],
                ),
                _formChat(),
                // voiceChat()
              ],
            ),
          ),
        ),
      ),
      //   body: SafeArea(
      //     child: Stack(
      //       children: [
      //         Column(
      //           children: [
      //             _topChat(),
      //             _bodyChat(),
      //             const SizedBox(
      //               height: 85,
      //             ),
      //           ],
      //         ),
      //         _formChat(),
      //       ],
      //     ),
      //   ),
      // create a speaker button
    );
  }

  void saveData(int value) {
    prefs.setInt("token", value);
  }

  int getData() {
    return prefs.getInt("token") ?? 1;
  }

  _topChat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Chat GPT',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          MySetting(),
        ],
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  Widget chats() {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: chatList.length,
      itemBuilder: (context, index) => _itemChat(
        chat: chatList[index].chat,
        message: chatList[index].msg,
      ),
      controller: _scrollController,
    );
  }

  Widget _bodyChat() {
    return Expanded(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45), topRight: Radius.circular(45)),
            color: Colors.white,
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              chats(),
            ],
          ),
        ),
      ),
    );
  }

  _itemChat({required int chat, required String message}) {
    return GestureDetector(
      onLongPress: () {
        _pc.open();
      },
      child: Row(
        mainAxisAlignment:
            chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: chat == 0
                    ? const Color.fromARGB(30, 213, 45, 202)
                    : Colors.indigo.shade50,
                borderRadius: chat == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
              ),
              child: chatWidget(message, isMe: chat == 0 ? true : false),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatWidget(String text, {bool isMe = false}) {
    return SizedBox(
      width: 250.0,
      child: DefaultTextStyle(
        style: TextStyle(
          color: isMe == true
              ? const Color.fromARGB(255, 213, 45, 202)
              : Colors.black,
          fontSize: 16,
        ),
        child: isMe
            ? Text(
                text.replaceFirst('\n\n', ''),
              )
            : AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    text.replaceFirst('\n\n', ''),
                  ),
                ],
                repeatForever: false,
                totalRepeatCount: 1,
              ),
        // child: AnimatedTextKit(
        //   animatedTexts: [
        //     ColorizeAnimatedText(
        //       text.replaceFirst('\n\n', ''),
        //       textStyle: const TextStyle(
        //         fontSize: 16,
        //         fontFamily: 'Horizon',
        //       ),
        //       colors: [
        //         Colors.purple,
        //         Colors.blue,
        //         Colors.yellow,
        //         Colors.red,
        //       ],
        //     ),
        //   ],
        //   repeatForever: false,
        //   totalRepeatCount: 1,
        // ),
      ),
    );
  }

  // how to close textfield keyboard
  void _closeKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  // Widget voiceChat() {
  //   return Positioned(
  //     bottom: MediaQuery.of(context).viewInsets.bottom,
  //     child: Container(
  //       width: MediaQuery.of(context).size.width,
  //       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
  //       color: Colors.white,
  //       child: Column(
  //         children: [
  //           TextField(
  //             maxLines: null,
  //             controller: mesageController,
  //             decoration: InputDecoration(
  //               hintText: 'Type your message...',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(30),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           InkWell(
  //             onTap: () {
  //               // convert voice to text
  //             },
  //             child: Container(
  //               child: CircleAvatar(
  //                 backgroundColor: Colors.white,
  //                 radius: 30,
  //                 child: AvatarGlow(
  //                   animate: _isListening,
  //                   glowColor: Theme.of(context).primaryColor,
  //                   endRadius: 75.0,
  //                   duration: const Duration(milliseconds: 2000),
  //                   repeatPauseDuration: const Duration(milliseconds: 100),
  //                   repeat: true,
  //                   child: FloatingActionButton(
  //                     onPressed: _listen,
  //                     child: Icon(_isListening ? Icons.mic : Icons.mic_none),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _formChat() {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        color: Colors.white,
        child: Column(
          children: [
            TextField(
              maxLines: null,
              controller: mesageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
                suffixIcon: InkWell(
                  onTap: (() async {
                    messagePrompt = mesageController.text.toString();

                    setState(() {
                      chatList.add(Chat(msg: messagePrompt, chat: 0));
                      mesageController.clear();
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    });

                    var submitGetChatsForm2 = await submitGetChatsForm(
                      context: context,
                      prompt: messagePrompt,
                      tokenValue: tokenValue,
                    );
                    chatList.addAll(submitGetChatsForm2);

                    setState(() {});
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  }),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Color.fromARGB(255, 243, 23, 202),
                    size: 28,
                  ),
                ),
                filled: true,
                fillColor: Colors.blueGrey.shade50,
                labelStyle: const TextStyle(fontSize: 12),
                contentPadding: const EdgeInsets.all(20),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade50),
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey.shade50),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // convert voice to text
              },
              child: AvatarGlow(
                animate: _isListening,
                glowColor: Theme.of(context).primaryColor,
                endRadius: 75.0,
                duration: const Duration(milliseconds: 2000),
                repeatPauseDuration: const Duration(milliseconds: 100),
                repeat: true,
                child: FloatingActionButton(
                  onPressed: _listen,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector MySetting() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter state) {
              return Container(
                height: 400,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: Color(0xFFF75555),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
                      child: DropdownButtonFormField(
                        items: models,
                        borderRadius: const BorderRadius.only(),
                        focusColor: Colors.amber,
                        onChanged: (String? s) {},
                        decoration:
                            const InputDecoration(hintText: "Select Model"),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
                      child: Align(
                          alignment: Alignment.topLeft, child: Text("Token")),
                    ),
                    Slider(
                      min: 0,
                      max: 1000,
                      activeColor: const Color(0xFFE58500),
                      inactiveColor: const Color.fromARGB(255, 230, 173, 92),
                      value: tokenValue.toDouble(),
                      onChanged: (value) {
                        state(() {
                          tokenValue = value.round();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.2,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              saveData(tokenValue);
                              Navigator.of(context).pop(false);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2.2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE58500),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
      child: const Icon(
        Icons.more_vert_rounded,
        size: 25,
        color: Colors.white,
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            mesageController.text = _text;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
        mesageController.clear();
      });
    }
  }
}
