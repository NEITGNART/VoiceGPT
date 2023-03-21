import 'package:avatar_glow/avatar_glow.dart';
import 'package:chatgpt/models/model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../common/constants.dart';
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
  final String _text = 'Press the button and start speaking';
  final ScrollController _scrollController = ScrollController();

  var _currentLocaleId;

  bool isDebounce = true;

  @override
  void initState() {
    super.initState();
    getModels();
    initPrefs();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/chat-bot.png"),
            ),
            SizedBox(width: 10),
            Text('Chat GPT'),
          ],
        ),
        actions: [
          MySetting(),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1F1F1F),
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

  _topChat() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(20),
              // color border
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const Text(
            'Chat GPT',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          MySetting(),
        ],
      ),
    );
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
          ),
          controller: _scrollController,
        ),
      ),
    );
  }

  _itemChat({required int chat, required String message}) {
    return Row(
      mainAxisAlignment:
          chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chat == 1
            ? const CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage("assets/images/chat-bot.png"),
              )
            : Container(),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color:
                  chat == 0 ? const Color(0xFF5F80F8) : const Color(0xFFEBF5FF),
              borderRadius: chat == 0
                  ? const BorderRadius.all(Radius.circular(20))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
            ),
            child: chatWidget(message, isMe: chat == 0 ? true : false),
          ),
        ),
      ],
    );
  }

  Widget chatWidget(String text, {bool isMe = false}) {
    return SizedBox(
      width: 250.0,
      child: DefaultTextStyle(
          style: TextStyle(
            color: isMe == true ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          child: isMe
              ? Text(
                  text.replaceFirst('\n\n', ''),
                )
              : Text(
                  text.replaceFirst('\n\n', ''),
                )
          // : AnimatedTextKit(
          //     animatedTexts: [
          //       TyperAnimatedText(
          //         text.replaceFirst('\n\n', ''),
          //       ),
          //     ],
          //     repeatForever: false,
          //     totalRepeatCount: 1,
          //   ),
          ),
    );
  }

  Widget _formChat() {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  autocorrect: true,
                  maxLength: textLimit,
                  onChanged: (value) {
                    messageController.text = value;
                    messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: messageController.text.length));
                    setState(() {
                      // if (value.length = textLimit) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       duration: Duration(milliseconds: 500),
                      //       content: Text(
                      //         'Message is too long',
                      //         style: TextStyle(color: Colors.white),
                      //       ),
                      //       backgroundColor: Colors.red,
                      //     ),
                      //   );
                      // }
                      // if (value.length >= 5 && isDebounce == true) {
                      //   isDebounce = false;

                      //   Timer(
                      //     const Duration(seconds: 3),
                      //     () {
                      //       isDebounce = true;
                      //     },
                      //   );
                      // }
                      // messagePrompt = value;
                    });
                  },
                  // croll if the textfield is overflow
                  maxLines: null,
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Typing or Press the Mic',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    prefixIcon: messageController.text.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                messageController.clear();
                                _isListening = false;
                                _speech.stop();
                              });
                            },
                            child: const Icon(
                              Icons.clear,
                              color: Colors.grey,
                            ),
                          )
                        : null,
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
              ),
              //  messageController.text.isNotEmpty
              if (messageController.text.isNotEmpty)
                InkWell(
                  onTap: (() async {
                    messagePrompt = messageController.text.toString();
                    _speech.cancel();
                    _isListening = false;
                    setState(() {
                      chatList.add(Chat(msg: messagePrompt, chat: 0));
                      chatList.add(Chat(msg: messagePrompt, chat: 1));
                      messageController.clear();
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    });
                    // var submitGetChatsForm2 = await submitGetChatsForm(
                    //   contex : nullt: context,
                    //   prompt: messagePrompt,
                    //   tokenValue: tokenValue,
                    // );
                    // chatList.addAll(submitGetChatsForm2);
                  }),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                )
            ],
          ),
          AvatarGlow(
              animate: _isListening,
              glowColor: Colors.green,
              endRadius: 60.0,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 500),
              repeat: true,
              child: InkWell(
                onTap: () {
                  _listen();
                },
                child: Container(
                  width: 80,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                      size: 50, color: Colors.white),
                ),
              )
              // child: FloatingActionButton(
              //   // increase the size of the button
              //   backgroundColor:
              //       _isListening ? Colors.green : Theme.of(context).primaryColor,
              //   onPressed: _listen,
              //   child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 80),
              // ),
              ),
        ],
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
          onResult: (val) => setState(
            () {
              messageController.text = val.recognizedWords;
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

  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}
