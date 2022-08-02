import 'package:chat_app/connector.dart' as connector;
import 'package:chat_app/model.dart';
import 'package:chat_app/screens/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Lobby extends StatelessWidget {
  const Lobby({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, child, inModel) {
          return Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(title: const Text('Lobby')),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/CreateRoom');
              },
            ),
            body: model.roomList.isEmpty
                ? const Center(
                    child: Text('There are no rooms yet. Why not add one?'),
                  )
                : ListView.builder(
                    itemCount: model.roomList.length,
                    itemBuilder: (context, index) {
                      Map room = model.roomList[index];
                      String roomName = room['roomName'] ?? '';
                      return Column(
                        children: [
                          ListTile(
                            leading: room['private']
                                ? const Icon(Icons.lock)
                                : const Icon(Icons.lock_open_rounded),
                            title: Text(roomName),
                            subtitle: Text(room['description']),
                            onTap: () {
                              if (room['private'] &&
                                  !model.roomInvites.containsKey(roomName) &&
                                  room['creator'] != model.userName) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                      content: Text(
                                          'Sorry, you can\'t enter a private room without an invite')),
                                );
                              } else {
                                connector.join(model.userName, roomName,
                                    (inStatus, inRoomDescription) {
                                  if (inStatus == 'joined') {
                                    model.setCurrentRoomName =
                                        inRoomDescription['roomName'];
                                    model.setCurrentRoomUserList =
                                        inRoomDescription['users'];
                                    model.setCurrentRoomEnabled = true;
                                    model.clearCurrentRoomMessages();

                                    if (inRoomDescription['creator'] ==
                                        model.userName) {
                                      model.setCreatorFunctionsEnabled = true;
                                    } else {
                                      model.setCurrentRoomEnabled = false;
                                    }
                                    Navigator.pushNamed(context, '/Room');
                                  } else if (inStatus == 'full') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 2),
                                        content:
                                            Text('Sorry, that room is full'),
                                      ),
                                    );
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
