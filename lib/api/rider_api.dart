import 'dart:convert';
import 'dart:io';
import 'package:backend/model/rider_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RiderApi {
  // final favoriteJson = jsonEncode(Favorite('one', 'two'));

  // final List data = json.decode(File('data.json').readAsStringSync());

  Future<Db> database() async {
    final db = await Db.create(
        'mongodb+srv://doadmin:L09xk278KUm156Np@eml-database-6c1feb38.mongo.ondigitalocean.com/admin?tls=true&authSource=admin&replicaSet=eml-database');
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
      if (query!.isNotEmpty) {
        final filteredList = await col.find(where.eq('name', query));
        mapJson = jsonEncode(filteredList);
      }
      return Response.ok(mapJson, headers: {'Content-Type': 'application/json'});
    });

    router.post('/driver', (Request request) async {
      final payload = await request.readAsString();
      final jsonMap = json.decode(payload);
      Db databases = await database();
      final col = databases.collection('riders');
      await col.insertOne(jsonMap);
      return Response.ok(jsonMap.toString());
    });

    router.delete('/driver/<name>', (Request request, String name) async {
      // final parsedName = int.tryParse(name);
      Db databases = await database();
      final col = databases.collection('riders');
      await col.deleteOne({"login": name});
      return Response.ok("Deleted $name");
    });

    router.patch('/driver/<name>/<param>', (Request request, String name, String param) async {
      final payload = await request.readAsString();
      final jsonMap = json.decode(payload);
      Db databases = await database();
      final col = databases.collection('riders');
      print(jsonMap["email"]);
      col.update(where.eq("login", name), modify.set(param, jsonMap[param]));
      return Response.ok("Updated $param of $name");
    });

    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}
