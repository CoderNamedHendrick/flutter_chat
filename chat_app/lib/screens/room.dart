import 'package:app_models/invite.dart';
import 'package:chat_app/connector.dart' as connector;
import 'package:chat_app/model.dart';
import 'package:chat_app/screens/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  bool _expanded = false;
  String? _postMessage;
  final ScrollController _controller = ScrollController();
  final TextEditingController _postEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(model.currentRoomName),
              actions: [
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'invite') {
                      _inviteOrKick(context, 'invite');
                    } else if (value == 'leave') {
                      connector.leave(model.userName, model.currentRoomName,
                          () {
                        model.removeRoomInvite(model.currentRoomName);
                        model.setCurrentRoomUserList = {};
                        model.setCurrentRoomName =
                            FlutterChatModel.defaultRoomName;
                        model.setCurrentRoomEnabled = false;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', ModalRoute.withName('/'));
                      });
                    } else if (value == 'close') {
                      connector.close(model.currentRoomName, () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', ModalRoute.withName('/'));
                      });
                    } else if (value == 'kick') {
                      _inviteOrKick(context, 'kick');
                    }
                  },
                  itemBuilder: (context) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem(
                          child: Text('Leave Room'), value: 'leave'),
                      const PopupMenuItem(
                          child: Text('Invite a User'), value: 'invite'),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                          child: const Text('Close Room'),
                          value: 'close',
                          enabled: model.creatorFunctionsEnabled),
                      PopupMenuItem(
                          child: const Text('Kick User'),
                          value: 'kick',
                          enabled: model.creatorFunctionsEnabled),
                    ];
                  },
                ),
              ],
            ),
            drawer: const AppDrawer(),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
              child: Column(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (inIndex, inExpanded) =>
                        setState(() => _expanded = !_expanded),
                    children: [
                      ExpansionPanel(
                        isExpanded: _expanded,
                        headerBuilder: (context, isExpanded) =>
                            const Text("Users In Room"),
                        body: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Builder(builder: (context) {
                            List<Widget> userList = [];
                            for (var user in model.currentRoomUserList) {
                              userList.add(Text(user['userName']));
                            }
                            return Column(children: userList);
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: model.currentRoomMessages.length,
                      itemBuilder: (context, index) {
                        Map message = model.currentRoomMessages[index];
                        return ListTile(
                          subtitle: Text(message['userName']),
                          title: Text(message['message']),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: _postEditingController,
                            onChanged: (inText) =>
                                setState(() => _postMessage = inText),
                            decoration: const InputDecoration.collapsed(
                                hintText: 'Enter message'),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            color: Colors.blue,
                            onPressed: () {
                              connector.post(
                                  model.userName,
                                  model.currentRoomName,
                                  _postMessage ?? '', (inStatus) {
                                if (inStatus == 'ok') {
                                  model.addMessage(
                                      model.userName, _postMessage ?? '');
                                  _controller.jumpTo(
                                      _controller.position.maxScrollExtent);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _inviteOrKick(BuildContext context, String inviteOrKick) {
    connector.listUsers((inUserList) {
      model.setUserList = inUserList;
      showDialog(
        context: context,
        builder: (dialogContext) {
          return ScopedModel<FlutterChatModel>(
            model: model,
            child: ScopedModelDescendant<FlutterChatModel>(
              builder: (context, inChild, inModel) {
                return AlertDialog(
                  title: Text('Select user to $inviteOrKick'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: double.maxFinite / 2,
                    child: ListView.builder(
                      itemCount: inviteOrKick == 'invite'
                          ? model.userList.length
                          : model.currentRoomUserList.length,
                      itemBuilder: (context, index) {
                        Map user;
                        if (inviteOrKick == 'invite') {
                          user = model.userList[index];
                        } else {
                          user = model.currentRoomUserList[index];
                        }

                        if (user['userName'] == model.userName) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border(
                              bottom: BorderSide(),
                              top: BorderSide(),
                              left: BorderSide(),
                              right: BorderSide(),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              stops: [.1, .2, .3, .4, .5, .6, .7, .8, .9],
                              colors: [
                                Color.fromRGBO(250, 250, 0, 0.75),
                                Color.fromRGBO(250, 220, 0, 0.75),
                                Color.fromRGBO(250, 190, 0, 0.75),
                                Color.fromRGBO(250, 160, 0, 0.75),
                                Color.fromRGBO(250, 130, 0, 0.75),
                                Color.fromRGBO(250, 110, 0, 0.75),
                                Color.fromRGBO(250, 80, 0, 0.75),
                                Color.fromRGBO(250, 50, 0, 0.75),
                                Color.fromRGBO(250, 0, 0, 0.75),
                              ],
                            ),
                          ),
                          margin: const EdgeInsets.only(top: 10.0),
                          child: ListTile(
                            title: Text(user['userName']),
                            onTap: () {
                              if (inviteOrKick == 'invite') {
                                connector.invite(
                                    Invite(
                                        userName: user['userName'],
                                        roomName: model.currentRoomName,
                                        inviterName: model.userName), //
                                    () {
                                  Navigator.of(context).pop();
                                });
                              } else {
                                connector.kick(
                                    user['userName'], model.currentRoomName,
                                    () {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }
}
