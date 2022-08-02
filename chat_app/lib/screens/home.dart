import 'package:chat_app/model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'app_drawer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(title: const Text('FlutterChat')),
            body: Center(
              child: Text(model.greeting),
            ),
          );
        },
      ),
    );
  }
}
