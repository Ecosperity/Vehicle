import 'dart:io';
import 'package:backend/api/rider_api.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main(List<String> arguments) async {
  final ip = InternetAddress.anyIPv4;
  var app = Router();

  final overrideHeaders = {
    'ACCESS_CONTROL_ALLOW_HEADERS': 'localhost',
    'Content-Type': 'application/json;charset=utf-8',
  };

  final handler = const Pipeline()
      .addMiddleware(
        corsHeaders(
          headers: overrideHeaders,
        ),
      )
      .addHandler(app);

  app.mount('/api/', RiderApi().router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  var server = await shelf_io.serve(handler, ip, port, shared: true);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');

/**************************************************************/

  Handler _wsHandler = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      webSocket.sink.add("echo $message");
    });
  });

  // Configure routes.
  final _router = Router()..get('/api/v1/users/ws', _wsHandler);

  // final wsIp = InternetAddress.anyIPv4;
// Configure a pipeline that logs requests.
  final wsHandler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  // final wsPort = int.parse(Platform.environment['PORT'] ?? '8080');

  final wsServer = await serve(wsHandler, ip, port, shared: true);
  print('Server listening on port ${wsServer.port}');
}
