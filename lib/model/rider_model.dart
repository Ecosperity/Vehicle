import 'package:json_annotation/json_annotation.dart';

part 'rider_model.g.dart';

@JsonSerializable()
class Favorite {
  final String title;
  final String artist;

  Favorite(this.title, this.artist);

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}