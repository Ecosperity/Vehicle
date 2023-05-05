import 'dart:convert';

import 'package:backend/model/rider_model.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';


class Api {
  Router get router {
    final router = Router();

    router.get('/driver', (Request request) {
      return Response.ok(jsonEncode(Favorite('one', 'two')));
    });

    router.post('/driver', (Request request) {
      return Response.ok(jsonEncode(Favorite('three', 'four')));
    });

    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}
