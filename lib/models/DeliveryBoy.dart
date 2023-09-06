
import 'dart:developer';

import 'package:EMallApp/utils/TextUtils.dart';

class DeliveryBoy{

  int id;
  String? name, email, avatarUrl, mobile;
  double? latitude, longitude;
  bool? isOffline;

  DeliveryBoy(this.id, this.name, this.email, this.avatarUrl, this.mobile,
      this.latitude, this.longitude,this.isOffline);

  static DeliveryBoy fromJson(Map<String, dynamic> jsonObject) {

    log("5.1");
    int id = int.parse(jsonObject['id'].toString());
    String? name = jsonObject['name'].toString();
    String? email = jsonObject['email'].toString();
    log("5.2");
    String? avatarUrl = jsonObject['avatar_url']==null ? "":
        TextUtils.getImageUrl(jsonObject['avatar_url'].toString());
    String mobile = jsonObject['mobile'].toString();
  log("5.3");
    double? latitude;
    if (jsonObject['lat'] != null)
      latitude = double.parse(jsonObject['lat'].toString());
    double? longitude;
    if (jsonObject['long'] != null)
      longitude = double.parse(jsonObject['long'].toString());
log("5.4");
    bool isOffline =jsonObject['isOffline'] ==null ? false  : jsonObject['isOffline'];
log("5.5");
  

    return DeliveryBoy(id, name, email, avatarUrl, mobile, latitude, longitude,isOffline);
  }

     DeliveryBoy fromMap(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());
    String name = jsonObject['name'].toString();
    String email = jsonObject['email'].toString();
    String? avatarUrl = jsonObject['avatar_url'] ==null ?"" :
        TextUtils.getImageUrl(jsonObject['avatar_url'].toString());
    String? mobile = jsonObject['mobile'] ==null ? "" : jsonObject['mobile'].toString();

    double? latitude;
    if (jsonObject['lat'] != null)
      latitude = double.parse(jsonObject['lat'].toString());
    double? longitude;
    if (jsonObject['long'] != null)
      longitude = double.parse(jsonObject['long'].toString());

    bool isOffline = jsonObject['isOffline'];

    return DeliveryBoy(id, name, email, avatarUrl, mobile, latitude, longitude,isOffline);
  }

    Map<String, dynamic> toMap({String lat="",String long=""}) {
    return <String, dynamic>{
      'id': id,
      'isOffline': isOffline,
      'name': name,
      'email':email,
     // 'token':token,
      'avatarUrl':'avatar_url',
      'mobile':mobile,
      "lat":lat,
      "long":long
    };
  }

  static List<DeliveryBoy> getListFromJson(List<dynamic> jsonArray) {
    List<DeliveryBoy> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(DeliveryBoy.fromJson(jsonArray[i]));
    }
    return list;
  }

  @override
  String toString() {
    return 'DeliveryBoy{id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, mobile: $mobile, latitude: $latitude, longitude: $longitude}';
  }
}