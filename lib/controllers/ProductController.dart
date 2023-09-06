import 'dart:convert';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Filter.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';



class ProductController{

  //------------------------ Get all products -----------------------------------------//
  static Future<MyResponse<List<Product>>> getAllProduct() async {
    //Get Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS;
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
      if (response.statusCode == 200) {
        List<Product> list =
            Product.getListFromJson(json.decode(response.body!));
        myResponse.success = true;
        myResponse.data = list;
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<List<Product>>();
    }
  }


  //------------------------ Get filtered product with shops -----------------------------------------//



  //------------------------ Get single product -----------------------------------------//
  static Future<MyResponse<Product>> getSingleProduct(int productId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.PRODUCTS + productId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Product>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<Product> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        Product product = Product.fromJson(json.decode(response.body!));
        myResponse.success = true;
        myResponse.data = product;
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Product>();
    }
  }


  static Future<MyResponse<Product>> getSingleProductReviews(int productId) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.PRODUCTS +
        productId.toString() +
        "/" +
        ApiUtil.REVIEWS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<Product>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<Product> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        Product product = Product.fromJson(json.decode(response.body!));
        myResponse.success = true;
        myResponse.data = product;
      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    }catch(e){
      //If any server error...
      return MyResponse.makeServerProblemError<Product>();
    }
  }




}