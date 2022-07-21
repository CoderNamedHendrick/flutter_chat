import 'user_descriptor.dart';

class Room {
  final String roomName;
  final String description;
  final int maxPeople;
  final bool private;
  final String creator;
  final Map<String, UserDescriptor> users;

  const Room({
    required this.roomName,
    required this.description,
    required this.maxPeople,
    required this.private,
    required this.creator,
    this.users = const {},
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomName: json['roomName'],
        description: json['description'],
        maxPeople: json['maxPeople'],
        private: json['private'],
        creator: json['creator'],
        users: json['users'],
      );

  Map<String, dynamic> toJson() => {
        'roomName': roomName,
        'description': description,
        'maxPeople': maxPeople,
        'private': private,
        'creator': creator,
        'users': users,
      };
}
