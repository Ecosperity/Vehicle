import 'dart:convert';
import 'dart:io';
import 'package:backend/model/rider_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RiderApi {
  // final List data = json.decode(File('data.json').readAsStringSync());
  String response = "";

  Future<Db> database() async {
    final db = await Db.create(
        'mongodb+srv://doadmin:wu3C5Y70p49Rey21@eml-database-6c1feb38.mongo.ondigitalocean.com/admin?tls=true&authSource=admin&replicaSet=eml-database');
    await db.open();
    return db;
  }

  Router get router {
    final router = Router();

    router.get('/driver', (Request request) async {
      String? query = request.url.queryParameters["query"];
      Db databases = await database();
      final col = databases.collection('riders');
      final list = await col.find().toList();
      var mapJson = jsonEncode(list);
      if (query != null) {
        final filteredList = await col.find(where.eq('name', query)).toList();
        mapJson = jsonEncode(filteredList);
      }
      return Response.ok(mapJson,
          headers: {'Content-Type': 'application/json'});
    });

    router.post('/driver', (Request request) async {
      final payload = await request.readAsString();
      final jsonMap = json.decode(payload);
      Db databases = await database();
      final col = databases.collection('riders');
      await col.insert(jsonMap);
      return Response.ok(jsonMap.toString());
    });

    router.delete('/driver/<name>', (Request request, String name) async {
      // final parsedName = int.tryParse(name);
      String? param = request.url.queryParameters["param"];
      Db databases = await database();
      final col = databases.collection('riders');

      if (param == 'all') {
        await col.deleteMany({"login": name});
      }
      else {
        await col.deleteOne({"login": name});
      }

      return Response.ok("Deleted $name");
    });

    router.patch('/driver/<name>', (Request request, String name) async {
      String? param = request.url.queryParameters["param"];
      final payload = await request.readAsString();
      final jsonMap = json.decode(payload);
      Db databases = await database();
      final col = databases.collection('riders');
      if (param != null) {
        col.update(where.eq("login", name), modify.set(param, jsonMap[param]));
        response = "Updated $param of $name";
      }
      else {
        response = "Unknown query.";
      }
      return Response.ok("Updated $param of $name");
    });

    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}
