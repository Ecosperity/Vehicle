import 'dart:convert';
import 'dart:io';

import 'package:backend/api/rider_api.dart';
import 'package:backend/backend.dart' as backend;
import 'package:backend/model/rider_model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';


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
  var server = await shelf_io.serve(handler, ip, port);
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}
