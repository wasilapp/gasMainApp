// To parse this JSON data, do
//
//     final category = categoryFromMap(jsonString);

import 'dart:convert';
import 'dart:developer';

List<Category> categoryFromMap(String str) => List<Category>.from(json.decode(str).map((x) => Category.fromMap(x)));

List<SubCategory> subCategoryFromMap(String str) => List<SubCategory>.from(json.decode(str).map((x) => SubCategory.fromMap(x)));

List<Shop> shopsFromMap(String str) => List<Shop>.from(json.decode(str).map((x) => Shop.fromMap(x)));

String categoryToMap(List<Category> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Category {
    Category({
        required this.id,
        required this.title,
        required this.commesion,
        required this.imageUrl,
        this.deliveryFee,
        required this.active,
        required this.createdAt,
        required this.updatedAt,
        required this.subCategories,
        required this.shops,
        required this.type,
    });

    int id;
    String title;
    double commesion;
    String imageUrl;
    dynamic deliveryFee;
    int active;
    String createdAt;
    String updatedAt;
    List<SubCategory> subCategories;
    List<Shop> shops;
    String type;

    factory Category.fromMap(Map<String, dynamic> json){
      log("here in the category");
      log(json.toString());
     return  Category(
        id: json["id"],
        title: json["title"],
        type:json["type"],
        commesion: json["commesion"]==null ? 0.0:  json["commesion"].toDouble() ,
        imageUrl: json["image_url"],
        deliveryFee:json["delivery_fee"]==null ? 0.0: json["delivery_fee"].toDouble(),
        active: json["active"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        subCategories: json["sub_categories"].isEmpty ? [] :  List<SubCategory>.from(json["sub_categories"].map((x) => SubCategory.fromMap(x))),
        shops:  json["shops"].isEmpty ? [] :  List<Shop>.from(json["shops"].map((x) => Shop.fromMap(x))),
    );
    }
    Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "commesion": commesion,
        "image_url": imageUrl,
        "delivery_fee": deliveryFee,
        "active": active,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "sub_categories": List<dynamic>.from(subCategories.map((x) => x.toMap())),
        "shops": List<dynamic>.from(shops.map((x) => x.toMap())),
    };
}

class Shop {
    Shop({
        required this.id,
        required this.name,
      //  required this.mangerName,
        required this.email,
        required this.mobile,
        required this.barcode,
        required this.latitude,
        required this.longitude,
        required this.address,
        required this.imageUrl,
        required this.rating,
        required this.deliveryRange,
        required this.totalRating,
        this.defaultTax,
        required this.availableForDelivery,
        required this.open,
        required this.managerId,
        required this.categoryId,
        required this.createdAt,
        required this.updatedAt,
    });

    int id;
    String name;
   // String mangerName;
    String email;
    String mobile;
    String barcode;
    double latitude;
    double longitude;
    String address;
    String imageUrl;
    int rating;
    int deliveryRange;
    int totalRating;
    int? defaultTax;
    int availableForDelivery;
    int open;
    int? managerId;
    int categoryId;
    String createdAt;
    String updatedAt;

    factory Shop.fromMap(Map<String, dynamic> json) => Shop(
        id: json["id"],
        name: json["name"],
      //  mangerName: json["mangerName"],
        email: json["email"],
        mobile: json["mobile"],
        barcode: json["barcode"],
        latitude:  json["latitude"]==null ? 0:  json["latitude"]?.toDouble(),
        longitude:  json["longitude"]==null ? 0: json["longitude"]?.toDouble(),
        address: json["address"],
        imageUrl: json["image_url"],
        rating: json["rating"],
        deliveryRange: json["delivery_range"],
        totalRating: json["total_rating"],
        defaultTax: json["default_tax"],
        availableForDelivery: json["available_for_delivery"],
        open: json["open"],
        managerId: json["manager_id"],
        categoryId: json["category_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
     //   "mangerName": mangerName,
        "email": email,
        "mobile": mobile,
        "barcode": barcode,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "image_url": imageUrl,
        "rating": rating,
        "delivery_range": deliveryRange,
        "total_rating": totalRating,
        "default_tax": defaultTax,
        "available_for_delivery": availableForDelivery,
        "open": open,
        "manager_id": managerId,
        "category_id": categoryId,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };

      static String getPlaceholderImage(){
    return './assets/images/placeholder/no-shop-image.png';
  }
}

class SubCategory {
    SubCategory({
        required this.id,
        required this.title,
        required this.price,
        required this.categoryId,
        required this.active,
        required this.createdAt,
        required this.updatedAt,
        required this.image_url,
    });

    int id;
    String title;
    double price;
    int categoryId;
    int active;
    String createdAt;
    String updatedAt;
   String image_url;

    factory SubCategory.fromMap(Map<String, dynamic> json) {
      
      log("in the sub");
      
     return SubCategory(
        id: json["id"],
        title: json["title"],
        price: json["price"]==null ? 0:  json["price"].toDouble(),
        categoryId: json["category_id"],
        active: json["active"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
         image_url: json["image_url"],
    );

    }

    Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "price": price,
        "category_id": categoryId,
        "active": active,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "image_url": image_url,
    };
}
