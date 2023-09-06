import 'package:EMallApp/models/Shop.dart';

import 'Category.dart';

class SubCategory {
  int id ;
  String title;
  double? price;



  SubCategory(
      this.id,  this.title, this.price,);

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    double price = double.parse(jsonObject['price'].toString());
    String title = jsonObject['title'].toString();


    return SubCategory(id,  title, price, );
  }

  static List<SubCategory> getListFromJson(List<dynamic> jsonArray) {
    List<SubCategory> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(SubCategory.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'SubCategory{id: $id,  title: $title,  price: $price}';
  }
}
