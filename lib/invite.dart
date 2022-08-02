class Invite {
  final String userName;
  final String roomName;
  final String inviterName;

  const Invite({
    required this.userName,
    required this.roomName,
    required this.inviterName,
  });

  factory Invite.fromJson(Map<String, dynamic> json) => Invite(
        userName: json['userName'],
        roomName: json['roomName'],
        inviterName: json['inviterName'],
      );

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'roomName': roomName,
        'inviterName': inviterName,
      };
}
