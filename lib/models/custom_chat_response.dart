class CustomChatResponse {
  String? text;
  String? conversationId;
  String? parentMessageId;

  CustomChatResponse({this.text, this.conversationId, this.parentMessageId});

  CustomChatResponse.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    conversationId = json['conversationId'];
    parentMessageId = json['parentMessageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['conversationId'] = conversationId;
    data['parentMessageId'] = parentMessageId;
    return data;
  }
}
