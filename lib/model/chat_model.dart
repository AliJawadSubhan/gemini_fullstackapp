class ChatModel {
  final String message;
  final bool isAi;

  ChatModel({
    required this.message,
    required this.isAi,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'],
      isAi: json['isAi'],
    );
  }
}
