import 'package:chat_app/connector.dart' as connector;
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Drawer(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.pinkAccent,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, 30 + MediaQuery.of(context).viewPadding.top, 0, 15),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Center(
                          child: Text(
                            model.userName,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(
                          model.currentRoomName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Lobby'),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/Lobby', ModalRoute.withName('/Lobby'));
                      connector.listRooms((inRoomList) {
                        print('[ROOM LIST RESPONSE]: $inRoomList');
                        model.setRoomList = inRoomList;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListTile(
                    leading: const Icon(Icons.room),
                    title: Text(model.currentRoomName),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/Room', ModalRoute.withName('/Room'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Users List'),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/UserList', ModalRoute.withName('/UserList'));
                      connector.listUsers((inUserList) {
                        model.setUserList = inUserList;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
