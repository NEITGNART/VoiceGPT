class CustomChatRequest {
  String? conversationId;
  String? parentMessageId;
  String? message;

  CustomChatRequest({this.conversationId, this.parentMessageId, this.message});

  CustomChatRequest.fromJson(Map<String, dynamic> json) {
    conversationId = json['conversationId'];
    parentMessageId = json['parentMessageId'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversationId'] = conversationId;
    data['parentMessageId'] = parentMessageId;
    data['message'] = message;
    return data;
  }
}
