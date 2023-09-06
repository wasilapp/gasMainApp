// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

import 'package:EMallApp/services/AppLocalizations.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    Order({
        required this.id,
        required this.status,
        required this.orderType,
        required this.order,
        required this.shopRevenue,
        required this.adminRevenue,
        required this.deliveryFee,
        required this.total,
        required this.otp,
        this.couponDiscount,
        required this.latitude,
        required this.longitude,
        this.couponId,
        this.deliveryBoyId,
        required this.userId,
        required this.addressId,
        required this.shopId,
        required this.orderPaymentId,
        required this.createdAt,
        required this.updatedAt,
        required this.carts,
        this.coupon,
        required this.address,
        this.deliveryBoy,
        required this.orderPayment,
        required this.orderTime,
          required this.shop,
    });

    int? id;
    int? status;
    int? orderType;
    double order;
    dynamic shopRevenue;
    dynamic adminRevenue;
    double deliveryFee;
    double total;
    int? otp;
    dynamic couponDiscount;
    double latitude;
    double longitude;
    dynamic couponId;
    dynamic deliveryBoyId;
    int? userId;
    int? addressId;
    int? shopId;
    int? orderPaymentId;
    String createdAt;
    String updatedAt;
    List<dynamic> carts;
    dynamic coupon;
    Address? address;
    dynamic deliveryBoy;
    OrderPayment? orderPayment;
    OrderTime? orderTime;
     Shop? shop;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        status: json["status"],
        orderType: json["order_type"],
        order: json["order"]?.toDouble(),
        shopRevenue: json["shop_revenue"]?.toDouble(),
        adminRevenue: json["admin_revenue"]?.toDouble(),
        deliveryFee: json["delivery_fee"]?.toDouble(),
        total: json["total"]?.toDouble(),
        otp: json["otp"],
        couponDiscount: json["coupon_discount"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        couponId: json["coupon_id"],
        deliveryBoyId: json["delivery_boy_id"],
        userId: json["user_id"],
        addressId: json["address_id"],
        shopId: json["shop_id"],
        orderPaymentId: json["order_payment_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        carts: List<dynamic>.from(json["carts"].map((x) => x)),
        coupon: json["coupon"],
        address: json["address"]!=null ?  Address.fromJson(json["address"]):null,
        deliveryBoy: json["delivery_boy"],
        orderPayment: json["order_payment"] != null ?   OrderPayment.fromJson(json["order_payment"]):null,
        shop:   json["shop"] != null ?   Shop.fromJson(json["shop"]):null ,

        orderTime: json["order_time"] != null ? OrderTime.fromJson(json["order_time"]) :null,
        
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "order_type": orderType,
        "order": order,
        "shop_revenue": shopRevenue,
        "admin_revenue": adminRevenue,
        "delivery_fee": deliveryFee,
        "total": total,
        "otp": otp,
        "coupon_discount": couponDiscount,
        "latitude": latitude,
        "longitude": longitude,
        "coupon_id": couponId,
        "delivery_boy_id": deliveryBoyId,
        "user_id": userId,
        "address_id": addressId,
        "shop_id": shopId,
        "order_payment_id": orderPaymentId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "carts": List<dynamic>.from(carts.map((x) => x)),
        "coupon": coupon,
        "address": address!=null ?  address!.toJson()  : null,
        "delivery_boy": deliveryBoy,
        "order_payment": orderPayment!.toJson(),
        "shop": shop!=null ? shop!.toJson(): null,
    };

    static List<Order> getListFromJson(List<dynamic> jsonArray) {
    List<Order> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Order.fromJson(jsonArray[i]));
    }
    return list;
  }

  static const int ORDER_CANCELLED_BY_SHOP = -2;
  static const int ORDER_CANCELLED_BY_USER = -1;
  static const int ORDER_WAIT_FOR_PAYMENT = 0;
  static const int ORDER_WAIT_FOR_CONFIRMATION = 1;
  static const int ORDER_ACCEPTED = 2;
  static const int ORDER_READY_FOR_DELIVERY = 3;
  static const int ORDER_ON_THE_WAY = 4;
  static const int ORDER_DELIVERED = 5;
  static const int ORDER_REVIEWED = 6;

  static const int ORDER_TYPE_PICKUP = 1;
  static const int ORDER_TYPE_DELIVERY = 2;

  static const int ORDER_PT_COD = 1;
  static const int ORDER_PT_RAZORPAY = 2;
  static const int ORDER_PT_PAYSTACK = 3;
  static const int ORDER_PT_STRIPE = 4;
    static const int ORDER_PT_WALLET = 5;

  static String getTextFromOrderStatus(int status, int? orderType) {
    if (Order.isPickUpOrder(orderType)) {
      switch (status) {
        case ORDER_CANCELLED_BY_SHOP:
          return Translator.translate("order_cancelled_by_shop");
        case ORDER_CANCELLED_BY_USER:
          return Translator.translate("order_cancelled_by_you");
        case ORDER_WAIT_FOR_PAYMENT:
          return Translator.translate("wait_for_payment");
        case ORDER_WAIT_FOR_CONFIRMATION:
          return Translator.translate("wait_for_confirmation");
        case ORDER_ACCEPTED:
          return Translator.translate("accepted_and_packaging");
        case ORDER_READY_FOR_DELIVERY:
          return Translator.translate("pickup_order_from_shop");
        case ORDER_ON_THE_WAY:
        case ORDER_DELIVERED:
          return Translator.translate("delivered");
        case ORDER_REVIEWED:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(ORDER_TYPE_PICKUP, orderType);
      }
    } else {
      switch (status) {
        case ORDER_CANCELLED_BY_SHOP:
          return Translator.translate("order_cancelled_by_shop");
        case ORDER_CANCELLED_BY_USER:
          return Translator.translate("order_cancelled_by_you");
          case ORDER_WAIT_FOR_PAYMENT:
          return Translator.translate("wait_for_payment");
        case ORDER_WAIT_FOR_CONFIRMATION:
          return Translator.translate("wait_for_confirmation");
        case ORDER_ACCEPTED:
          return Translator.translate("accepted_and_packaging");
        case ORDER_READY_FOR_DELIVERY:
          return Translator.translate("wait_for_delivery_boy");
        case ORDER_ON_THE_WAY:
          return Translator.translate("on_the_way");
        case ORDER_DELIVERED:
          return Translator.translate("delivered");
        case ORDER_REVIEWED:
          return Translator.translate("reviewed");
        default:
          return getTextFromOrderStatus(ORDER_TYPE_PICKUP, orderType);
      }
    }
  }

  static String getTextFromOrderType(int type) {
    switch (type) {
      case ORDER_TYPE_PICKUP:
        return Translator.translate("self_pickup");
      case ORDER_TYPE_DELIVERY:
        return Translator.translate("home_delivery");
    }
    return getTextFromOrderType(ORDER_TYPE_DELIVERY);
  }



  static bool checkWaitForPayment(int status) {
    return status == ORDER_WAIT_FOR_PAYMENT;
  }

  static bool checkStatusDelivered(int status) {
    return status == ORDER_DELIVERED;
  }

  static bool checkStatusReviewed(int status) {
    return status == ORDER_REVIEWED;
  }

  static bool isSuccessfulDelivered(int status){
    return status>=ORDER_DELIVERED;
  }

  static String getPaymentTypeText(int paymentType) {
    switch (paymentType) {
      case ORDER_PT_WALLET:
        return Translator.translate("wallet");
      case ORDER_PT_COD:
        return Translator.translate("cash_on_delivery");
      case ORDER_PT_RAZORPAY:
        return Translator.translate("Razorpay");
      case ORDER_PT_PAYSTACK:
        return Translator.translate("Paystack");
      case ORDER_PT_STRIPE:
        return Translator.translate("Stripe");
    }
    return getPaymentTypeText(ORDER_PT_COD);
  }

  static bool isPaymentByCOD(int paymentType) {
    return paymentType == ORDER_PT_COD;
  }

 

  static bool isPaymentByRazorpay(int paymentType) {
    return paymentType == ORDER_PT_RAZORPAY;
  }

  static bool isPaymentByPaystack(int paymentType) {
    return paymentType == ORDER_PT_PAYSTACK;
  }

  static bool isPaymentByStripe(int paymentType) {
    return paymentType == ORDER_PT_STRIPE;
  }

    static bool isPaymentByWallet(int paymentType) {
    return paymentType == ORDER_PT_WALLET;
  }

  static bool isOrderCompleteWithReview(int status) {
    return status == ORDER_REVIEWED;
  }

  static double getDiscountFromCoupon(double originalOrderPrice, int offer) {
    return originalOrderPrice * offer / 100;
  }

  static bool isPickUpOrder(int? orderType) {
    return orderType == ORDER_TYPE_PICKUP;
  }

  static bool isCancellable(int orderStatus) {
    return orderStatus < ORDER_ACCEPTED;
  }

  static bool isCancelled(int orderStatus){
    return orderStatus==ORDER_CANCELLED_BY_USER || orderStatus==ORDER_CANCELLED_BY_SHOP;
  }
}

class Address {
    Address({
        required this.id,
        required this.longitude,
        required this.latitude,
        required this.address,
        this.address2,
        required this.city,
        required this.addressDefault,
        required this.pincode,
        required this.active,
        required this.type,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
    });

    int id;
    String longitude;
    String latitude;
    String address;
    dynamic address2;
    String city;
    int? addressDefault;
    int? pincode;
    int? active;
    int? type;
    int? userId;
    String createdAt;
    String updatedAt;

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json["id"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        address: json["address"],
        address2: json["address2"],
        city: json["city"],
        addressDefault: json["default"],
        pincode: json["pincode"],
        active: json["active"],
        type: json["type"],
        userId: json["user_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "longitude": longitude,
        "latitude": latitude,
        "address": address,
        "address2": address2,
        "city": city,
        "default": addressDefault,
        "pincode": pincode,
        "active": active,
        "type": type,
        "user_id": userId,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}

class OrderPayment {
    OrderPayment({
        required this.id,
        required this.paymentType,
        required this.success,
        this.paymentId,
        required this.createdAt,
        required this.updatedAt,
    });

    int? id;
    int? paymentType;
    int? success;
    dynamic? paymentId;
    String? createdAt;
    String? updatedAt;

    factory OrderPayment.fromJson(Map<String, dynamic> json) => OrderPayment(
        id: json["id"],
        paymentType: json["payment_type"],
        success: json["success"],
        paymentId: json["payment_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "payment_type": paymentType,
        "success": success,
        "payment_id": paymentId,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };





    
}


// To parse this JSON data, do
//
//     final orderTime = orderTimeFromJson(jsonString);



OrderTime orderTimeFromJson(String str) => OrderTime.fromJson(json.decode(str));

String orderTimeToJson(OrderTime data) => json.encode(data.toJson());

class OrderTime {
    OrderTime({
        required this.id,
        required this.orderDate,
        required this.orderTime,
        required this.orderId,
        required this.createdAt,
        required this.updatedAt,
    });

    int id;
    String orderDate;
    String orderTime;
    int orderId;
    String createdAt;
    String updatedAt;

    factory OrderTime.fromJson(Map<String, dynamic> json) => OrderTime(
        id: json["id"],
        orderDate: json["order_date"],
        orderTime: json["order_time"],
        orderId: json["order_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "order_date": orderDate,
        "order_time": orderTime,
        "order_id": orderId,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}



class Shop {
    Shop({
        required this.id,
        required this.name,
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
        required this.defaultTax,
        required this.availableForDelivery,
        required this.open,
        required this.managerId,
        required this.categoryId,
        required this.createdAt,
        required this.updatedAt,
    });

    int id;
    String name;
    String email;
    String mobile;
    String barcode;
    double latitude;
    double longitude;
    String address;
    String imageUrl;
    int? rating;
    int? deliveryRange;
    int? totalRating;
    int? defaultTax;
    int? availableForDelivery;
    int? open;
    int? managerId;
    int? categoryId;
    String createdAt;
    String updatedAt;

    factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        barcode: json["barcode"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
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

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
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
}





 