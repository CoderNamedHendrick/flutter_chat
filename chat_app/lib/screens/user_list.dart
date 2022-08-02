import 'package:chat_app/model.dart';
import 'package:chat_app/screens/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class UserList extends StatelessWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(title: const Text('User List')),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemCount: model.userList.length,
              itemBuilder: (context, index) {
                Map user = model.userList[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: GridTile(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Icon(
                          Icons.person,
                          size: 48,
                        ),
                      ),
                    ),
                    footer: Text(
                      user['userName'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
