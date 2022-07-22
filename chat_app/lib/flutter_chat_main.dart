import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'model.dart';

class FlutterChatMain extends StatelessWidget {
  const FlutterChatMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    return ScopedModelDescendant<FlutterChatModel>(
      builder: (inContext, inChild, inModel) {
        return MaterialApp(
          initialRoute: '/',
          routes: {
            '/Lobby': (screenContext) => Lobby(),
            '/Room': (screenContext) => Room(),
            '/UserList': (screenContext) => UserList(),
            '/CreateRoom': (screenContext) => CreateRoom(),
          },
          home: Home(),
        );
      },
    );
  }
}
