class Message {
  final String userName;
  final String message;

  const Message({required this.userName, required this.message});

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(userName: json['userName'], message: json['message']);

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'message': message,
      };
}
