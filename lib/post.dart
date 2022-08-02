class Post {
  final String userName;
  final String roomName;
  final String message;

  const Post({
    required this.userName,
    required this.roomName,
    required this.message,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      userName: json['userName'],
      roomName: json['roomName'],
      message: json['message']);

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'roomName': roomName,
        'message': message,
      };
}
