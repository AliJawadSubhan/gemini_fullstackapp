class ChatModel {
  final String message;
  final bool isAi;
  final String? path;

  ChatModel({
    required this.message,
    required this.isAi,
    required this.path,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'],
      isAi: json['isAi'],
      path: null,
    );
  }
}
