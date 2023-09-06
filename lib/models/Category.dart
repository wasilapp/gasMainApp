

import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/utils/TextUtils.dart';

import 'SubCategory.dart';

class Category {
  int? id;
  String title;
  String imageUrl;
  List<SubCategory>? subcategories;
  List<Shop>? shops;

  Category(
      this.id ,this.title, this.imageUrl, this.subcategories,this.shops);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String title = jsonObject['title'].toString();

    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());


    List<SubCategory>? subcategories;
    if (jsonObject['sub_categories'] != null) {
      subcategories = SubCategory.getListFromJson(jsonObject['sub_categories']);
    }
    List<Shop>? shops;
    if (jsonObject['shops'] != null) {
      shops = Shop.getListFromJson(jsonObject['shops']);
    }

    return Category(id,  title,  imageUrl, subcategories,shops);
  }

  static List<Category> getListFromJson(List<dynamic> jsonArray) {
    List<Category> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Category.fromJson(jsonArray[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Category{id: $id, title: $title,  imageUrl: $imageUrl}';
  }
}
