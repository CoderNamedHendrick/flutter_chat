import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

FlutterChatModel model = FlutterChatModel();

class FlutterChatModel extends Model {
  late BuildContext rootBuildContext;
  late final Directory docDir;
  String greeting = '';
  String userName = '';

  static const String defaultRoomName = 'Not currently in a room';

  String currentRoomName = defaultRoomName;

  List currentRoomUserList = [];

  bool currentRoomEnabled = false;

  List currentRoomMessages = [];

  List roomList = [];

  List userList = [];

  bool creatorFunctionsEnabled = false;

  Map roomInvites = {};

  set setGreeting(String inGreeting) {
    greeting = inGreeting;
    notifyListeners();
  }

  set setUserName(String inUserName) {
    userName = inUserName;
    notifyListeners();
  }

  set setCurrentRoomName(String roomName) {
    currentRoomName = roomName;
    notifyListeners();
  }

  set setCreatorFunctionsEnabled(bool enabled) {
    creatorFunctionsEnabled = enabled;
    notifyListeners();
  }

  set setCurrentRoomEnabled(bool enabled) {
    currentRoomEnabled = enabled;
    notifyListeners();
  }

  void addMessage(String inUserName, String inMessage) {
    currentRoomMessages.add({'userName': inUserName, 'message': inMessage});
    notifyListeners();
  }

  set setRoomList(Map inRoomList) {
    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }

    roomList = rooms;
    notifyListeners();
  }

  set setUserList(Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    userList = users;
    notifyListeners();
  }

  set setCurrentRoomUserList(Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    currentRoomUserList = users;
    notifyListeners();
  }

  void addRoomInvite(String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  void removeRoomInvite(String inRoomName) {
    roomInvites.remove(inRoomName);
  }

  void clearCurrentRoomMessages() {
    currentRoomMessages = [];
  }
}
