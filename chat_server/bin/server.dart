import 'dart:convert';
import 'dart:io';

import 'package:app_models/models.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WebSocketCallback = void Function(
    WebSocketChannel io, Map<String, dynamic>? inData);

final _clients = <WebSocketChannel>[];
final _socketStreams = <int, Stream>{};
final users = <String, UserDescriptor>{};
final rooms = <String, Room>{};

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/fc', webSocketHandler(_handler));

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void _handler(WebSocketChannel webSocket) {
  _clients.add(webSocket);
  stdout.writeln('[CONNECTED]]');
  _socketStreams[webSocket.hashCode] = webSocket.stream.asBroadcastStream();

  webSocket.on('connection', (io, inData) {
    stdout.writeln('[RECEIVED]: $inData');
    stdout.writeln('[STREAMS ON SERVER]: ${_socketStreams.length}');
    stdout.writeln('[SOCKETS ON SERVER]: ${_clients.length}');
    io.sink.add('connect');
  });

  webSocket.on('validate', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    final u = UserDescriptor.fromJson(inData!);
    final user = users[u.userName];
    if (user != null) {
      if (user.password == u.password) {
        io.sink.add(jsonEncode({'status': 'ok'}));
      } else {
        io.sink.add(jsonEncode({'status': 'fail'}));
      }
    } else {
      users[u.userName] = u;
      io.broadcast('newUser', users);
      io.sink.add(jsonEncode({'status': 'created'}));
    }
  });

  webSocket.on('create', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    final r = Room.fromJson(inData!);
    if (rooms.containsKey(r.roomName)) {
      io.sink.add(jsonEncode({'status': 'exists'}));
    } else {
      rooms[r.roomName] = r;
      io.broadcast('created', rooms);
      io.sink.add(jsonEncode({'status': 'created', 'data': rooms}));
    }
  });

  webSocket.on('listRooms', (io, inData) {
    io.sink.add(jsonEncode({'data': rooms}));
  });

  webSocket.on('listUsers', (io, inData) {
    io.sink.add(jsonEncode({'data': users}));
  });

  webSocket.on('join', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    final r = rooms[inData!['roomName']];
    if (r == null) throw 'Room Doesn\'t exist';
    if (r.users!.length >= r.maxPeople) {
      io.sink.add(jsonEncode({'status': 'full'}));
    } else {
      final u = users[inData['userName']];
      if (u == null) throw 'User doesn\'t exist';

      r.users![inData['userName']] = u;
      io.broadcast('joined', r);
      io.sink.add(jsonEncode({'status': 'joined', 'data': r}));
    }
  });

  webSocket.on('post', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    io.broadcast('posted', inData);
    io.sink.add(jsonEncode({'status': 'ok'}));
  });

  webSocket.on('invite', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    io.broadcast('invited', inData);
    io.sink.add(jsonEncode({'status': 'ok'}));
  });

  webSocket.on('leave', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    final r = rooms[inData!['roomName']];
    r?.users!.remove(inData['userName']);
    io.broadcast('left', r);
    io.sink.add(jsonEncode({'status': 'ok'}));
  });

  webSocket.on('close', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    rooms.remove(inData!['roomName']);
    io.broadcast('closed', {'roomName': inData['roomName'], 'rooms': rooms});
    io.sink.add(jsonEncode(rooms));
  });

  webSocket.on('kick', (io, inData) {
    assert(inData != null, 'Data shouldn\'t be null for this call');
    final r = rooms[inData!['roomName']];
    if (r == null) throw 'Room Doesn\'t exist';

    final users = r.users;
    users!.remove(inData['userName']);
    io.broadcast('kicked', r);
    io.sink.add(jsonEncode({'status': 'ok'}));
  });
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(_handler, ip, port);
  print('Server listening on port ${server.port}');
}

extension StreamHandler on Stream {}

extension SocketChannelHandler on WebSocketChannel {
  void on(String connectionMessage, WebSocketCallback webSocket) {
    _socketStreams[hashCode]?.listen(
      (event) {
        final worker = SocketCallbackModel.fromJson(
            jsonDecode(event) as Map<String, dynamic>);
        if (worker.message == connectionMessage) {
          print(worker.data);
          webSocket.call(this, worker.data);
        }
      },
      onError: (error) {
        stderr.writeln(error);
      },
      cancelOnError: false,
      onDone: () {
        stdout.writeln('[DONE]');
        _socketStreams.remove(hashCode);
        _clients.remove(this);
      },
    );
  }

  void broadcast<T>(String message, T object) {
    _clients.emit(message, object, this);
  }
}

extension ClientsListHandler on List<WebSocketChannel> {
  void emit<T>(String message, T object, WebSocketChannel current) {
    final clients =
        where((element) => element.hashCode != current.hashCode).toList();
    for (final client in clients) {
      client.sink.add(jsonEncode({'message': message, 'data': object}));
    }
  }
}
