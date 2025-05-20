// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

part 'favorite.g.dart';

@HiveType(typeId: 0)
class Favorite extends HiveObject {
  @HiveField(0)
  String idCategory;

  @HiveField(1)
  String strCategory;

  @HiveField(2)
  String strCategoryThumb;

  @HiveField(3)
  String strCategoryDescription;
  Favorite({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryThumb,
    required this.strCategoryDescription,
  });
}
