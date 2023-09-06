import 'package:EMallApp/models/Shop.dart';

import 'Category.dart';

class ShopTime {
  int id, shop_id;
  String? start_time;
  String? end_time;




  ShopTime(
      this.id, this.start_time, this.end_time,this.shop_id );

  static fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    int shop_id = int.parse(jsonObject['shop_id'].toString());
    String start_time = jsonObject['start_time'].toString();
    String end_time = jsonObject['end_time'].toString();


    return ShopTime(id,  start_time,end_time,shop_id, );
  }

  static List<ShopTime> getListFromJson(List<dynamic> jsonArray) {
    List<ShopTime> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(ShopTime.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'ShopTime{id: $id, shop_id: $shop_id, start_time: $start_time, end_time: $end_time, }';
  }
}
