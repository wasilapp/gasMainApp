
import 'package:EMallApp/models/ShopTime.dart';
import 'package:EMallApp/models/SubCategory.dart';
import 'package:EMallApp/utils/TextUtils.dart';

import 'Manager.dart';


class Shop {


  int? id, managerId,category_id;

  String name;
  int quantity;
  String email;
  String mobile;
  double latitude, longitude;
  String address;
  String imageUrl;
  int totalRating;
  double rating;

  int tax, deliveryRange;

  bool availableForDelivery;
  bool isOpen;


  Manager? manager;

  Shop(
      this.id,
      this.managerId,
      this.category_id,


      this.name,
      this.quantity,
      this.email,
      this.mobile,
      this.latitude,
      this.longitude,
      this.address,
      this.imageUrl,
      this.totalRating,
      this.rating,
      this.tax,
      this.deliveryRange,
      this.availableForDelivery,
      this.isOpen,



      this.manager,

      );

  static fromJson(Map<String, dynamic> jsonObject) {

    int id = int.parse(jsonObject['id'].toString());
    String name = jsonObject['name'].toString();
    int quantity = int.parse(jsonObject['quantity'].toString());
    String email = jsonObject['email'].toString();
    String mobile = jsonObject['mobile'].toString();
    double latitude = double.parse(jsonObject['latitude'].toString());
    double longitude = double.parse(jsonObject['longitude'].toString());
    String address = jsonObject['address'].toString();
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());

    int totalRating = int.parse(jsonObject['total_rating'].toString());
    double rating = double.parse(jsonObject['rating'].toString());

    int tax = int.parse(jsonObject['default_tax'].toString());
    int deliveryRange =
    int.parse(jsonObject['delivery_range'].toString());
    bool availableForDelivery =
        TextUtils.parseBool(jsonObject['available_for_delivery'].toString());
    bool isOpen = TextUtils.parseBool(jsonObject['open']);


    int? managerId;
    if (jsonObject['manager_id'] != null)
      managerId = int.parse(jsonObject['manager_id'].toString());

    int? category_id;
    if (jsonObject['category_id'] != null)
      category_id = int.parse(jsonObject['category_id'].toString());


    Manager? manager;
    if (jsonObject['manager'] != null)
      manager = Manager.fromJson(jsonObject['manager']);


    return Shop(
        id,
        managerId,
      category_id,

        name,
      quantity,
        email,
        mobile,
        latitude,
        longitude,

        address,
        imageUrl,
        totalRating,
        rating,
        tax,
        deliveryRange,
        availableForDelivery,
        isOpen,
        manager,

    );
  }

  static List<Shop> getListFromJson(List<dynamic> jsonArray) {
    List<Shop> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Shop.fromJson(jsonArray[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Shop{id: $id, managerId: $managerId,quantity,$quantity, category_id: $category_id, name: $name,  email: $email, mobile: $mobile, latitude: $latitude, longitude: $longitude, address: $address, imageUrl: $imageUrl, totalRating: $totalRating, rating: $rating, tax: $tax, deliveryRange: $deliveryRange, availableForDelivery: $availableForDelivery, isOpen: $isOpen,  manager: $manager, }';
  }

  static String getPlaceholderImage(){
    return './assets/images/placeholder/no-shop-image.png';
  }

}
