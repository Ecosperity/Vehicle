import 'dart:convert';
import 'dart:io';
import 'package:backend/model/rider_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RiderApi {
  final jsonData = [
    {
      "id": 1,
      "first_name": "Seamus",
      "last_name": "Prinne",
      "email": "sprinne0@unc.edu",
      "gender": "Male",
      "city": "Paris La Défense"
    },
    {
      "id": 2,
      "first_name": "Allis",
      "last_name": "Loosemore",
      "email": "aloosemore1@ca.gov",
      "gender": "Genderqueer",
      "city": "Guarujá"
    },
  ];

  // final favoriteJson = jsonEncode(Favorite('one', 'two'));

  // final List data = json.decode(File('data.json').readAsStringSync());

  Future<Db> database() async {
    final db = await Db.create(
        'mongodb+srv://doadmin:L09xk278KUm156Np@eml-database-6c1feb38.mongo.ondigitalocean.com/admin?tls=true&authSource=admin&replicaSet=eml-database');
    await db.open();
    return db;
  }

  Future<void> dbInsert(Map<String, String> map) async {
    Db databases = await database();
    final col = databases.collection('riders');
    col.insert(map);
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
      // Map<String, String> map = json.decode(payload);
      // print(map);
      dbInsert(json.decode(payload));
      return Response.ok(json.decode(payload));
    });

    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));
    return router;
  }
}
