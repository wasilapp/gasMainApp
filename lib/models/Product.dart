
import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/models/Category.dart';
import 'package:EMallApp/models/ProductImage.dart';
import 'package:EMallApp/models/ProductItem.dart';
import 'package:EMallApp/models/ProductReview.dart';
import 'package:EMallApp/models/SubCategory.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:flutter/material.dart';

import 'Shop.dart';

class Product {
  int id, shopId,sub_category_id;
  String? name;
  String? description;
  String imageUrl;
  double rating;
  int totalRating;
  int offer;
  bool isFavorite;

  Shop? shop;
  SubCategory? subCategory;

  List<ProductReview>? reviews;

  Product(
      this.id,

      this.shopId,
      this.sub_category_id,
      this.subCategory,
      this.name,
      this.description,
      this.imageUrl,
      this.rating,
      this.totalRating,
      this.offer,
      this.isFavorite,

      this.shop,

      this.reviews);

  static Product fromJson(Map<String, dynamic> jsonObject) {
    int id = int.parse(jsonObject['id'].toString());

    int shopId = int.parse(jsonObject['shop_id'].toString());
    int sub_category_id = int.parse(jsonObject['sub_category_id'].toString());
    String? name = jsonObject['name'];
    String? description = jsonObject['description'];
    String imageUrl = TextUtils.getImageUrl(jsonObject['image_url'].toString());

    int offer = int.parse(jsonObject['offer'].toString());
    double rating = double.parse(jsonObject['rating'].toString());
    int totalRating = int.parse(jsonObject['total_rating'].toString());
    bool isFavorite = TextUtils.parseBool(jsonObject['is_favorite'].toString());


    SubCategory? subCategory;
    if (jsonObject['subCategory'] != null)
      subCategory = SubCategory.fromJson(jsonObject['subCategory']);

    Shop? shop;
    if (jsonObject['shop'] != null) shop = Shop.fromJson(jsonObject['shop']);


    List<ProductReview>? reviews;
    if (jsonObject['product_reviews'] != null)
      reviews = ProductReview.getListFromJson(jsonObject['product_reviews']);

    return Product(
        id,

        shopId,
        sub_category_id,
        subCategory,
        name,
        description,
      imageUrl,
        rating,
        totalRating,
        offer,
        isFavorite,

        shop,

        reviews,

    );
  }

  static List<Product> getListFromJson(List<dynamic> jsonArray) {
    List<Product> list = [];
    for (int i = 0; i < jsonArray.length; i++) {
      list.add(Product.fromJson(jsonArray[i]));
    }
    return list;
  }


  @override
  String toString() {
    return 'Product{id: $id, shopId: $shopId,sub_category_id:$sub_category_id, subCategory:$subCategory,name: $name, description: $description,imageUrl:$imageUrl, rating: $rating, totalRating: $totalRating, offer: $offer, isFavorite: $isFavorite,  shop: $shop, reviews: $reviews}';
  }

  static Text getTextFromQuantity(int quantity, TextStyle style,
      ThemeData? themeData, CustomAppTheme? customAppTheme) {
    Color color;
    String text;
    if (quantity > 8) {
      color = themeData!.colorScheme.onBackground;
      text = Translator.translate("in_stock");
    } else if (quantity > 4) {
      color = customAppTheme!.colorInfo;
      text = Translator.translate("few_items_available");
    } else if (quantity > 0) {
      color = customAppTheme!.colorError;
      text = Translator.translate("only") +
          " " +
          quantity.toString() +
          " " +
          Translator.translate("items_available");
    }else{
      color = customAppTheme!.colorError;
      text = Translator.translate("stock_out");
    }

    return Text(text,style: style.copyWith(color: color),);
  }

  static Widget offerTextWidget(
      {double? originalPrice,
      int? offer,
      ThemeData? themeData,
      CustomAppTheme? customAppTheme,
      double fontSize = 18}) {
    if (offer == 0) {
      return Text(CurrencyApi.getSign(afterSpace: true) + originalPrice.toString(),
          style: AppTheme.getTextStyle(themeData!.textTheme.caption,
              color: themeData.colorScheme.onBackground,
              fontSize: fontSize,
              fontWeight: 600,
              letterSpacing: 0,
              wordSpacing: -1));
    } else {
      double discountedPrice = getOfferedPrice(originalPrice!, offer!);

      return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyApi.getSign(afterSpace: true) +
                  CurrencyApi.doubleToString(discountedPrice),
              style: AppTheme.getTextStyle(themeData!.textTheme.caption,
                  color: themeData.colorScheme.onBackground,
                  fontWeight: 600,
                  fontSize: fontSize,
                  letterSpacing: 0.2,
                  height: 0),
            ),
            Container(
              margin: Spacing.left(4),
              child: Text( CurrencyApi.getSign(afterSpace: true) +  CurrencyApi.doubleToString(originalPrice),
                  style: AppTheme.getTextStyle(themeData.textTheme.caption,
                      color: themeData.colorScheme.onBackground,
                      fontWeight: 500,
                      fontSize: fontSize * 0.6,
                      letterSpacing: 0,
                      wordSpacing: -1,height: 0,muted: true,
                      decoration: TextDecoration.lineThrough)),
            ),
          ],
        ),
      );
    }
  }


  static double getOfferedPrice(double originalPrice,int offer){
    return originalPrice * (1 - offer / 100);
  }



  static String getPlaceholderImage(){
    return './assets/images/placeholder/no-product-image.png';
  }




}
