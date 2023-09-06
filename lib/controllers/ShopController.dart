import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Filter.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/models/SubCategory.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';

import 'AuthController.dart';

class ShopController {


  //------------------------ Get single shop -----------------------------------------//
  static Future<MyResponse<Shop>> getSingleShop(int? shopId) async {
    print("shop staart");
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS + shopId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Shop>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<Shop> myResponse = MyResponse(response.statusCode);
      print(response.statusCode);

      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        print("shop done");
        myResponse.success = true;
        myResponse.data = Shop.fromJson(json.decode(response.body!));

      } else {
        print("shop failed4");
        myResponse.success = false;
        myResponse.setError(json.decode(response.body!));
      }
      return myResponse;
    }catch(e){
      print("shop failed");
      //If any server error...
      return MyResponse.makeServerProblemError<Shop>();
    }
  }


  //------------------------ Get Shop Sub Category -----------------------------------------//
  static Future<MyResponse<List<SubCategory>>> getShopSubCategory(int shopId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.SHOPS +
        shopId.toString() +
        "/" +
        "subCategories";
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<SubCategory>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<SubCategory>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        print("sub done");
        myResponse.success = true;
        myResponse.data = SubCategory.getListFromJson(json.decode(response.body!));
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print("sub error");
      //If any server error...
      return MyResponse.makeServerProblemError<List<SubCategory>>();
    }
  }

  //------------------------ Get subcategory products -----------------------------------------//

  static Future<MyResponse<List<Product>>> getSubCategoryProducts(int subCategoryId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
       "subCategories/${subCategoryId.toString()}/products";
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Product>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<Product>> myResponse = MyResponse(response.statusCode);
    print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        print("subproducts done");
        myResponse.success = true;
        myResponse.data = Product.getListFromJson(json.decode(response.body!));
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print("subproducts error");
      print(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Product>>();
    }
  }

  //------------------------ Get all shop -----------------------------------------//
  static Future<MyResponse<List<Shop>>> getAllShop() async {
    print("shop staart2");
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOPS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Shop>>();
    }

    try {
      print("shop staart44");
      NetworkResponse response = await Network.get(url, headers: headers);

      MyResponse<List<Shop>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Shop.getListFromJson(json.decode(response.body!));
        print("respomsettt${response.body}");
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body!));
      }
      return myResponse;
    } catch (e) {
      print(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }





  //------------------------ Get all shop -----------------------------------------//
  static Future<MyResponse<List<Shop>>> getShopsFromUserAddress(
      int userAddressId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.SHOPS +
        ApiUtil.ADDRESSES +
        userAddressId.toString();

    Map<String, String> headers = ApiUtil.getHeader(
      requestType: RequestType.GetWithAuth,
      token: token,
    );

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Shop>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<Shop>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Shop.getListFromJson(json.decode(response.body!));
      } else {
        myResponse.success = false;
        myResponse.setError(json.decode(response.body!));
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }

  /////////////////////////////// search shop   /////////////////////////////

  static Future<MyResponse<List<Shop>>> getFilteredShop(Filter filter) async {

    //Create some body data
    //String query = "";
    /*   if (filter.subCategories.length != 0) {
      subCategoryIds = "sub_category_ids=";
      for (int i = 0; i < filter.subCategories.length; i++) {
        subCategoryIds += filter.subCategories[i].toString();
        if (i < filter.subCategories.length - 1) {
          subCategoryIds += ",";
        }
      }
    }*/

    String query = "";
    if (filter.name.length != 0) {
      query = "query=" + filter.name;
    }

    String min_price = "";

      min_price = "min_price=" + filter.min_price.toString();


    String max_price = "";

      max_price = "max_price=" + filter.max_price.toString();


    //Getting User Api Token
    print("max_price$max_price");
    print("min_price$min_price");

    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        "shop/search"
        "?" +
        query +
        "&" +
        min_price +
        "&" +
        max_price;
    print(url);
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Shop>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<Shop>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        print("sear star");
        List<Shop> list =
        Shop.getListFromJson(json.decode(response.body!));
        myResponse.success = true;
        myResponse.data = list;
        print("sear done");
      } else {
        print("sear err");
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }
}
