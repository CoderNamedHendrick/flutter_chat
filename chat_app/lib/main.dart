import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

import 'login_dialog.dart';
import 'model.dart' show FlutterChatModel, model;
import 'screens/screens.dart';

void main() {
  startMeUp() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    model.docDir = docDir;

    var credentialsFile = File(p.join(model.docDir.path, 'credentials'));
    var exists = await credentialsFile.exists();

    String credentials;
    if (exists) {
      credentials = await credentialsFile.readAsString();
      List credParts = credentials.split('============');
      const LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
          context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (inDialogContext) {
            return const LoginDialog();
          });
    }
  }

  runApp(const FlutterChat());
  startMeUp();
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

class FlutterChatMain extends StatelessWidget {
  const FlutterChatMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    return ScopedModel(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (context, inChild, inModel) {
          return Navigator(
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const Home());
                case '/Lobby':
                  return MaterialPageRoute(builder: (_) => const Lobby());
                case '/Room':
                  return MaterialPageRoute(builder: (_) => const Room());
                case '/UserList':
                  return MaterialPageRoute(builder: (_) => const UserList());
                case '/CreateRoom':
                  return MaterialPageRoute(builder: (_) => const CreateRoom());
                default:
                  return _errorRoute();
              }
            },
            // home: const Home(),
          );
        },
      ),
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        backgroundColor: Colors.red.shade300,
        body: const Center(
          child: Text('Page not found!'),
        ),
      );
    });
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
