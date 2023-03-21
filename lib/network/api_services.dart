import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chatgpt/models/custom_chat_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../errors/exceptions.dart';
import '../models/custom_chat_response.dart';
import '../models/images.dart';
import '../models/model.dart';
import '../utils/constants.dart';
import 'error_message.dart';
import 'network_client.dart';

Future<List<Images>> submitGetImagesForm({
  required BuildContext context,
  required String prompt,
  required int n,
}) async {
  //
  NetworkClient networkClient = NetworkClient();
  List<Images> imagesList = [];
  try {
    final res = await networkClient.post(
      '${BASE_URL}images/generations',
      {"prompt": prompt, "n": n, "size": "256x256"},
      token: OPEN_API_KEY,
    );
    Map<String, dynamic> mp = jsonDecode(res.toString());
    debugPrint(mp.toString());
    if (mp['data'].length > 0) {
      imagesList = List.generate(mp['data'].length, (i) {
        return Images.fromJson(<String, dynamic>{
          'url': mp['data'][i]['url'],
        });
      });
      debugPrint(imagesList.toString());
    }
  } on RemoteException catch (e) {
    Logger().e(e.dioError);
    errorMessage(context);
  }
  return imagesList;
}

Future<String> submitGetChatsForm({
  required BuildContext context,
  required String prompt,
  required int tokenValue,
  String? model,
}) async {
  //
  NetworkClient networkClient = NetworkClient();
  String chatList = "";
  try {
    final res = await networkClient.post(
      "${BASE_URL}completions",
      {
        "model": model ?? "text-davinci-003",
        "prompt": prompt,
        "temperature": 0,
        "max_tokens": tokenValue
      },
      token: OPEN_API_KEY,
    );
    Map<String, dynamic> mp = jsonDecode(res.toString());
    if (mp['choices'].length > 0) {
      chatList = mp['choices'][0]['text'];
      for (int i = 1; i < mp['choices'].length; i++) {
        chatList = chatList + mp['choices'][i]['text'];
      }
      return chatList;
      // chatList = List.generate(mp['choices'].length, (i) {
      //   logger.e(mp['choices'][i]['text']);
      //   return Chat.fromJson(<String, dynamic>{
      //     'msg': mp['choices'][i]['text'],
      //     'chat': 1,
      //   });
      // });
    }
  } on RemoteException catch (e) {
    Logger().e(e.dioError);
    errorMessage(context);
  }
  return chatList;
}

Future<List<Model>> submitGetModelsForm({
  required BuildContext context,
}) async {
  //
  NetworkClient networkClient = NetworkClient();
  List<Model> modelsList = [];
  try {
    final res = await networkClient.get(
      "${BASE_URL}models",
      token: OPEN_API_KEY,
    );
    Map<String, dynamic> mp = jsonDecode(res.toString());
    debugPrint(mp.toString());
    if (mp['data'].length > 0) {
      modelsList = List.generate(mp['data'].length, (i) {
        return Model.fromJson(<String, dynamic>{
          'id': mp['data'][i]['id'],
          'created': mp['data'][i]['created'],
          'root': mp['data'][i]['root'],
        });
      });
      debugPrint(modelsList.toString());
    }
  } on RemoteException catch (e) {
    Logger().e(e.dioError);
    errorMessage(context);
  }
  return modelsList;
}

final dio = Dio(BaseOptions(
  baseUrl: 'https://a6b7-2a09-bac5-d46d-16d2-00-246-e.ap.ngrok.io',
  contentType: 'application/json',
));

Future<Uint8List> synthesizeSpeech(String text) async {
  final response = await dio.post(
    '/synthesize',
    data: {'text': text},
    options: Options(
      responseType: ResponseType.bytes,
    ),
  );
  return response.data;
}

abstract class ChatRepository {
  Future<List<CustomChatResponse>> send({
    required BuildContext context,
    required CustomChatRequest chat,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<CustomChatResponse>> send(
      {required BuildContext context, required CustomChatRequest chat}) async {
    NetworkClient networkClient = NetworkClient();
    List<CustomChatResponse> chatList = [];
    try {
      final res = await networkClient.post(
        "localhost:3000/continue-chat",
        {"message": chat.message, "temperature": 0},
      );
      Map<String, dynamic> mp = jsonDecode(res.toString());
      debugPrint(mp.toString());
    } on RemoteException catch (e) {
      Logger().e(e.dioError);
    }
    return chatList;
  }
}
