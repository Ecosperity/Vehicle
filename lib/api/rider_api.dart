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

  Future<void> dbInsert() async {
    Db databases = await database();
    final col = databases.collection('riders');
    await col.insertOne({"login": "doe", "name": "John Doe", "email": "john@doe.com"});
  }

  Future<List<Map<String, dynamic>>> dbGet() async {
    Db databases = await database();
    final col = databases.collection('riders');
    return await col.find().toList();
  }

  Router get router {
    final router = Router();

    router.get('/driver', (Request request) async {
      var dataMap = await RiderApi().dbGet();
      return Response.ok(jsonEncode(dataMap));
    });

    router.post('/driver', (Request request) async {
      final payload = await request.readAsString();
      final jsonMap = json.decode(payload);
      print(jsonMap);
      // data = {"login": jsonMap["login"].toString(), "name": jsonMap["name"].toString(), "email": jsonMap["email"].toString()};
      // data = {"login": "doe", "name": "John Doe", "email": "john@doe.com"};
      Db databases = await database();
      final col = databases.collection('riders');
      await col.insertOne(jsonMap);
      return Response.ok(jsonMap.toString());
    });

    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}