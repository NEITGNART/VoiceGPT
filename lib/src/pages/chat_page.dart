// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:chatgpt/common/app_sizes.dart';
import 'package:chatgpt/models/custom_chat_request.dart';
import 'package:chatgpt/network/admob_service_helper.dart';
import 'package:chatgpt/src/pages/history/model/chat_adapter.dart';
import 'package:chatgpt/src/pages/setting/representation/controller.dart';
import 'package:chatgpt/src/pages/setting/representation/my_setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../common/constants.dart';
import '../../models/chat.dart';
import '../../network/api_services.dart';
import '../../utils/Admob.dart';
import '../chat/presentation/audio_waves.dart';
import 'chat/my_reuse_text.dart';
import 'chat/representation/my_arrow_icon.dart';
import 'chat/representation/my_chat_message.dart';
import 'chat/representation/my_template_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class Template {
  final String id;
  final String title;
  final String message;

  Template(this.id, this.title, this.message);
}

class _ChatPageState extends State<ChatPage> {
  String messagePrompt = '';
  List<Chat> chatList = [];
  late SharedPreferences prefs;
  bool isPlayingSound = false;
  ChatRepository chatRepository = ChatRepositoryImpl();
  final _assetsAudioPlayer = AssetsAudioPlayer();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final ScrollController _scrollController = ScrollController();
  late final audio.AudioPlayer player = audio.AudioPlayer();
  String? _currentLocaleId;
  String conversationId = '${DateTime.now().millisecondsSinceEpoch}';
  String parentMessageId = '';
  int soundPlayingIndex = -1;
  final Map<int, bool> soundPlayingMap = {};
  TextEditingController messageController = TextEditingController();
  bool hasOpenTemplate = false;
  int chatLimit = 15;
  final MoreSettingController c = Get.find<MoreSettingController>();
  final HistoryChatController historyController =
      Get.find<HistoryChatController>();

  RewardedAd? _rewardAd;
  AdManager adManager = AdManager();
  @override
  void initState() {
    super.initState();
    initPrefs();
    _createRewardedAd();

    _speech = Get.find<stt.SpeechToText>();
    soundPlayingMap[soundPlayingIndex] = false;
    _assetsAudioPlayer.playlistFinished.listen(
      (finished) {
        if (finished) {
          if (mounted) {
            setState(
              () {
                soundPlayingMap[soundPlayingIndex] = false;
              },
            );
          }
        }
      },
    );

    player.onPlayerStateChanged.listen(
      (audio.PlayerState s) {
        if (s == audio.PlayerState.stopped ||
            s == audio.PlayerState.paused ||
            s == audio.PlayerState.completed) {
          if (mounted) {
            setState(
              () {
                soundPlayingMap[soundPlayingIndex] = false;
              },
            );
          }
        }
      },
    );

    player.onPlayerComplete.listen(
      (event) {
        if (mounted) {
          setState(
            () {
              soundPlayingMap[soundPlayingIndex] = false;
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    player.dispose();
    _assetsAudioPlayer.dispose();
    _scrollController.dispose();
    messageController.dispose();
    _rewardAd?.dispose();
    super.dispose();
  }

  void initPrefs() {
    prefs = Get.find<SharedPreferences>();
    _currentLocaleId = prefs.getString('localeId');
    setState(() {});
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdMobService.chatRewardId!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardAd = ad;
          // Logger().e('Admob: Rewarded ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          // Logger().e('Admob: Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  void _showRewardAd() {
    if (_rewardAd != null) {
      _rewardAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createRewardedAd();
        },
      );
      _rewardAd!.show(
        onUserEarnedReward: (ad, reward) {
          setState(() {
            chatLimit += reward.amount.toInt();
          });
        },
      );
      _rewardAd = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            player.dispose();
            _assetsAudioPlayer.dispose();
            _rewardAd?.dispose();
            Get.back();
            // Get.back can't pop to root
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("assets/images/chat-bot.png"),
            ),
            const SizedBox(width: 10),
            Text('botname'.tr),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            onPressed: () {
              Get.to(() => const MySetting());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // _topChat(),
            Expanded(child: _bodyChat()),
            _formChat(),
          ],
        ),
      ),
    );
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
                            : const BorderRadius.all(Radius.circular(20))),
                    child: SelectableText(message,
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
                                  BorderRadius.all(Radius.circular(20))),
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
        if (mounted) {
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
            _assetsAudioPlayer.pause();
            player.pause();
            return;
          }
          final Directory tempDir = await getTemporaryDirectory();
          final String path = "${tempDir.path}/synthesized_audio_$id.mp3";
          // check if file exists
          final File file = File(path);
          file.exists().then(
            (value) async {
              if (value) {
                await _assetsAudioPlayer.open(
                  Audio.file(path),
                  // pause
                );
              } else {
                if (mounted) {
                  try {
                    if (message.length > 400) {
                      Get.snackbar('message_title'.tr, 'message_long'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: 3.seconds);
                    }
                    final audioBytes = await synthesizeSpeech(message);
                    if (Platform.isIOS) {
                      if (mounted) {
                        await file.writeAsBytes(audioBytes);
                        await _assetsAudioPlayer.open(
                          Audio.file(path),
                        );
                      }
                    } else {
                      if (mounted) {
                        final byteSouce = audio.BytesSource(audioBytes);
                        await player.play(byteSouce);
                        await file.writeAsBytes(audioBytes);
                      }
                    }
                  } catch (e) {
                    rethrow;
                  }
                }
              }
            },
          );
        }
      } catch (e) {
        Get.snackbar('sound_title'.tr, 'sound_error'.tr,
            snackPosition: SnackPosition.BOTTOM, duration: 3.seconds);
      }
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
              GestureDetector(
                onTap: () {
                  setState(() {
                    hasOpenTemplate = !hasOpenTemplate;
                  });
                },
                child: Container(
                  height: 50,
                  width: 25,
                  decoration: const BoxDecoration(),
                  child: ArrowIconAnimation(isExpanded: hasOpenTemplate),
                ),
              ),
              gapW12,
              Expanded(
                child: TextField(
                  buildCounter: (BuildContext context,
                          {required int currentLength,
                          required bool isFocused,
                          required int? maxLength}) =>
                      null,
                  // display scroll on keyboard on the right
                  autocorrect: true,
                  autofocus: true,
                  maxLength: textLimit,
                  // focus on the textfield
                  onChanged: (value) {
                    setState(
                      () {
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
                      },
                    );
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
                                left: MediaQuery.of(context).size.width * 0.1),
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
              //  messageController.text.isNotEmpty

              if (chatLimit > 0 &&
                  (!_isListening && messageController.text.isEmpty)) ...{
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

              if (chatLimit <= 0) ...{
                Center(
                  child: IconButton(
                    onPressed: () {
                      _showRewardAd();
                    },
                    icon: const Icon(
                      Icons.whatshot_outlined,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),
                )
              },

              if (chatLimit > 0 &&
                  (messageController.text.isNotEmpty || _isListening))
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
                          // Logger().e('chatLimit $chatLimit');
                          if (chatLimit <= 1) {
                            Get.snackbar(
                                'chat_limit_title'.tr, 'chat_limit_content'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: 5.seconds);
                          }
                          if (chatLimit <= 0) {
                            return;
                          }
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

                          if (c.isAutoSaveChatValue) {
                            historyController.addChat(chatList[n - 2]);
                          }

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

                            final result = Chat(
                                msg: reponse?.text ?? 'service_err'.tr,
                                chat: 1,
                                id: parentMessageId);
                            chatList[n - 1] = result;

                            if (c.isAutoSaveChatValue) {
                              historyController.addChat(result);
                            }

                            if (c.isAutoPlayValue) {
                              try {
                                await playSound(
                                    reponse?.text ?? 'service_err'.tr,
                                    parentMessageId,
                                    n - 1);
                              } catch (e) {
                                rethrow;
                              }
                            }
                          } catch (e) {
                            chatList[n - 1] = Chat(
                                msg: 'service_err'.tr,
                                chat: 1,
                                id: parentMessageId);
                          }
                          if (mounted) {
                            setState(() {
                              messageController.clear();
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            });
                          }

                          chatLimit -= 1;
                          if (mounted) {
                            setState(() {});
                          }
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
          if (hasOpenTemplate) ...{
            Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'template'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // icon +
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const MyTextReuse());
                        },
                        child: const Icon(
                          Icons.add,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                  Expanded(
                      child:
                          TemplateList(messageController: messageController)),
                ],
              ),
            ),
          }
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
