import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'flutter_chat_main.dart';
import 'model.dart' show model;

void main() {
  startMeUp() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    model.docDir = docDir;

    var credentialsFile = File(join(model.docDir.path, 'credentials'));
    var exists = await credentialsFile.exists();

    var credentials;
    if (exists) {
      credentials = await credentialsFile.readAsString();
      List credParts = credentials.split('============');
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
          context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (inDialogContext) {
            return LoginDialog();
          });
    }
  }

  startMeUp();
  runApp(const FlutterChat());
}

class FlutterChat extends StatelessWidget {
  const FlutterChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(body: FlutterChatMain()),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// const socketUrl = 'ws://localhost:8080/fc';
//
// class _MyHomePageState extends State<MyHomePage> {
//   late WebSocketChannel channel;
//
//   @override
//   void initState() {
//     super.initState();
//     channel = WebSocketChannel.connect(Uri.parse(socketUrl));
//
//     channel.stream.listen((event) {
//       print(event);
//     });
//   }
//
//   @override
//   void dispose() {
//     channel.sink.close();
//     super.dispose();
//   }
//
//   void _testCommand() {
//     channel.sink.add(jsonEncode(
//       {
//         'message': 'connection',
//       },
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               'Default State',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _testCommand,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
