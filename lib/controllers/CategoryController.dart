import 'dart:convert';
import 'dart:developer';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Categories.dart';

import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';


import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';

class CategoryController {
  //------------------------ Get all categories -----------------------------------------//
  static Future<MyResponse<List<Category>>> getAllCategory() async {
    print("category sttart");
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CATEGORIES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Category>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<List<Category>> myResponse = MyResponse(response.statusCode);
      log(response.body.toString());
      if (response.statusCode == 200) {
        log("category done");
        
        List<Category> list =
            categoryFromMap(response.body!);
          log("category done 2");
        myResponse.success = true;
        myResponse.data = list;
        
      } else {
        print("category error");
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      log(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Category>>();
    }
  }


  //------------------------ Get category SubCategory -----------------------------------------//
  static Future<MyResponse<List<SubCategory>>> getCategorySubCategories(int categoryId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.CATEGORIES +
        categoryId.toString() +
        "/" +
        ApiUtil.SUBCATEGORIES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<SubCategory>>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      log(response.body.toString());
      MyResponse<List<SubCategory>> myResponse = MyResponse(response.statusCode);
      print("shop sta");
      if (response.statusCode == 200) {
        print("shop done");
        myResponse.success = true;
        print(response.body);
        myResponse.data = subCategoryFromMap(response.body!);

      } else {
        print("shop error");
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<SubCategory>>();
    }
  }

  //------------------------ Get category shop -----------------------------------------//

  static Future<MyResponse<List<Shop>>> getCategoryShops(int categoryId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.CATEGORIES +
        categoryId.toString() +
        "/" +
        ApiUtil.SHOPS;
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
      print("shop sta");
      if (response.statusCode == 200) {
        print("shop done");
        myResponse.success = true;
        print(response.body);
        myResponse.data = shopsFromMap(response.body!);

      } else {
        print("shop error");
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }


    static Future<MyResponse<List<Shop>>> getCategoryShopsSearch(int categoryId,search) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.CATEGORIES +
        categoryId.toString() +
        "/" +
        ApiUtil.SHOPS + "?search=$search";
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
      print("shop sta");
      if (response.statusCode == 200) {
        print("shop done");
        myResponse.success = true;
        print(response.body);
        myResponse.data = shopsFromMap(response.body!);

      } else {
        print("shop error");
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Shop>>();
    }
  }




}
