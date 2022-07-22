import 'dart:convert';

import 'package:chat_app/models/cb_socket.dart';
import 'package:chat_app/models/user_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'model.dart';
import 'models/room.dart';

const socketUrl = 'ws://localhost:8080/fc';

late WebSocketChannel _channel;

void connectToServer(final Function inCallback) {
  _channel = WebSocketChannel.connect(Uri.parse(socketUrl));

  _channel.stream.listen((event) {
    if (event == 'connect') {
      _channel.subscribe('newUser', newUser);
      _channel.subscribe('created', created);
      _channel.subscribe('closed', closed);
      _channel.subscribe('joined', joined);
      _channel.subscribe('left', left);
      _channel.subscribe('kicked', kicked);
      _channel.subscribe('invited', invited);
      _channel.subscribe('posted', posted);
      inCallback.call();
    }
  });
}

// client-bound message handlers
void newUser(data) {
  Map<String, dynamic> payload = data;
  model.setUserList = payload;
}

void created(data) {
  Map<String, dynamic> payload = data;
  model.setRoomList = payload;
}

void closed(data) {
  Map<String, dynamic> payload = data;
  model.setRoomList = payload;
  if (payload['roomName'] == model.currentRoomName) {
    model.removeRoomInvite(payload['roomName']);
    model.setCurrentRoomUserList = {};
    model.setCurrentRoomName = FlutterChatModel.defaultRoomName;
    model.setCurrentRoomEnabled = false;
    model.setGreeting = 'The room you were in was closed by its creator.';
    Navigator.of(model.rootBuildContext)
        .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }
}

void joined(data) {
  Map<String, dynamic> payload = data;
  if (model.currentRoomName == payload['roomName']) {
    model.setCurrentRoomUserList = payload['users'];
  }
}

void left(data) {
  Map<String, dynamic> payload = data;
  if (model.currentRoomName == payload['roomName']) {
    model.setCurrentRoomUserList = payload['users'];
  }
}

void kicked(data) {
  Map<String, dynamic> payload = data;
  model.setRoomList = payload;
  if (payload['roomName'] == model.currentRoomName) {
    model.removeRoomInvite(payload['roomName']);
    model.setCurrentRoomUserList = {};
    model.setCurrentRoomName = FlutterChatModel.defaultRoomName;
    model.setCurrentRoomEnabled = false;
    model.setGreeting = 'The room you were in was closed by its creator.';
    Navigator.of(model.rootBuildContext)
        .pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }
}

void invited(data) async {
  Map<String, dynamic> payload = data;
  String roomName = payload['roomName'];
  String inviterName = payload['inviterName'];
  model.addRoomInvite(roomName);
  ScaffoldMessenger.of(model.rootBuildContext).showSnackBar(SnackBar(
    content: Text(
      'You\'ve been invited to the room '
      '\'$roomName\' by user \'$inviterName\'.\n\n'
      'You can enter the room from the lobby.',
    ),
    action: SnackBarAction(label: 'Ok', onPressed: () {}),
  ));
}

void posted(data) {
  Map<String, dynamic> payload = data;
  if (model.currentRoomName == payload['roomName']) {
    model.addMessage(payload['userName'], payload['message']);
  }
}

// Calls to the socket

void validate(UserDescriptor user) {
  showPleaseWait();
  final sb = SocketCallbackModel(message: 'validate', data: user.toJson());
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void listRooms() {
  showPleaseWait();
  final sb = SocketCallbackModel(message: 'listRooms', data: {});
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void create(Room room) {
  showPleaseWait();
  final sb = SocketCallbackModel(message: 'create', data: room.toJson());
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void join(String username, String roomName) {
  showPleaseWait();
  final sb = SocketCallbackModel(
      message: 'join', data: {'userName': username, 'roomName': roomName});
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void leave(String username, String roomName) {
  showPleaseWait();
  final sb = SocketCallbackModel(
      message: 'leave', data: {'userName': username, 'roomName': roomName});
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void listUsers() {
  showPleaseWait();
  final sb = SocketCallbackModel(message: 'listUsers');
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void invite(String userName, String roomName, String inviterName) {
  showPleaseWait();
  final sb = SocketCallbackModel(message: 'invite', data: {
    'userName': userName,
    'roomName': roomName,
    'inviterName': inviterName
  });
  _channel.sink.add(jsonEncode(sb.toJson()));
}

void post(String userName, String roomName, String message) {
  showPleaseWait();
  final s = SocketCallbackModel(
      message: 'post',
      data: {'userName': userName, 'roomName': roomName, 'message': message});

  _channel.sink.add(jsonEncode(s.toJson()));
}

void close(String roomName) {
  showPleaseWait();
  final s = SocketCallbackModel(message: 'close', data: {'roomName': roomName});
  _channel.sink.add(jsonEncode(s.toJson()));
}

void kick(String userName, String roomName) {
  showPleaseWait();
  final s = SocketCallbackModel(
      message: 'kick', data: {'userName': userName, 'roomName': roomName});
  _channel.sink.add(jsonEncode(s.toJson()));
}

extension ChannelHandler on WebSocketChannel {
  void subscribe(String message, Function(dynamic) cb) {
    stream.listen((event) {
      final result = jsonDecode(event);
      if (result['status'] == message) cb.call(result['data']);
    });
  }
}

void showPleaseWait() {
  showDialog(
    context: model.rootBuildContext,
    barrierDismissible: false,
    builder: (BuildContext inDialogContext) {
      return Dialog(
        child: Container(
          width: 150,
          height: 150,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(color: Colors.blue[200]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 10,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Center(
                  child: Text(
                    'Please wait, contacting server...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void hidePleaseWait() {
  Navigator.of(model.rootBuildContext).pop();
}
