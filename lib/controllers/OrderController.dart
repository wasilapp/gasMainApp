import 'dart:convert';
import 'dart:developer';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/models/OrderReview.dart';
import 'package:EMallApp/models/WalletsModel.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:EMallApp/utils/TextUtils.dart';

import 'AuthController.dart';


class OrderController {

  static WalletsModel? walletsForUser ;


  //------------------------ Add order from carts -----------------------------------------//
  static Future<MyResponse<Order>> addOrder(
      double order,
      double deliveryFee,
      double total,
      String deliveryIds,
      int paymentType,
      int status,
      int orderType,
      int quantity,
      int type,

      {int? addressId,
      String? orderDate,
      String? orderTime,
    }) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDING__Driver_ORDER_USER;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body Data
    Map data = {
      'payment_type': paymentType,
      'order': order,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status,
      'order_type':orderType,
      'deliveryIds' : deliveryIds,
      'address_id': addressId,
      'count' :quantity,
      'type' : type,
      'order_date' : orderDate ,
      'order_time' :  orderTime 
    
      
    };

    log(data.toString());

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(url, headers: headers, body: body);
      
      
      log(response.body.toString());
      MyResponse<Order> myResponse = MyResponse(response.statusCode);

      
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {

        myResponse.success = true;
        myResponse.data = Order.fromJson(json.decode(response.body!));
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
         MyResponse<Order> myResponse = MyResponse(400);
        myResponse.success = false;
        myResponse.setError({"error" : e.toString()});
      return myResponse;
     // return MyResponse.makeServerProblemError();
    }
  }


    static Future<MyResponse<Order>> addOrderForShop(
      double order,
      double deliveryFee,
      double total,
      String shopId,
      int paymentType,
      int status,
      int orderType,
      int type,
      int quantity,
      {int? addressId,
        String? orderDate,
      String? orderTime,
    }) async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDING_ORDER_USER;

    log(url);
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body Data
    Map data = {
      'payment_type': paymentType,
      'order': order,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status,
      'order_type':orderType,
      'shop_id' : shopId,
      'address_id': addressId,
      'type' : type,
      'count' :quantity,
      'order_date' : orderDate ?? "" ,
      'order_time' :  orderTime  ?? ""
    
      
    };

    log(data.toString());

   log("1");

    //Encode
    String body = json.encode(data);

  log("2");
    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();

      log("3");
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
      
    }

       log("4");

    try {
      NetworkResponse response = await Network.post(url, headers: headers, body: body);
      
         log("5");
      log("reponse body: "+response.body.toString() + " end");
      MyResponse<Order> myResponse = MyResponse(response.statusCode);

           log("6");
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
     log("7");
        myResponse.success = true;
             log("8");
        myResponse.data = Order.fromJson(json.decode(response.body!));
             log("9");
      } else {
             log("10");
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      log(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }



  //------------------------ Get all orders -----------------------------------------//
  static Future<MyResponse<List<Order>>> getAllOrder() async {

    //Get API Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ADDING_ORDER_USER;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      log( "all_orders: " +response.body.toString());
      MyResponse<List<Order>> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Order.getListFromJson(json.decode(response.body!)["orders"]);
      } else {
        Map<String, dynamic> data = json.decode(response.body!);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){

      log(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<List<Order>>();
    }
  }



    static Future<MyResponse<WalletsModel>> getWalletsData() async {

    //Get API Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.GET_WALLET;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      log( "all_wallets: " +response.body.toString());

      MyResponse<WalletsModel> myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = WalletsModel.fromJson( json.decode(response.body!) );

        walletsForUser = WalletsModel.fromJson( json.decode(response.body!) );
        log(walletsForUser!.total.toString());
      } else {
        Map<String, dynamic> data = json.decode(response.body!);

        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){

      log(e.toString());
      //If any server error...
      return MyResponse.makeServerProblemError<WalletsModel>();
    }
  }

  checkIfUserHaveWallet(shopId,total,type){}


  //------------------------ Get single order -----------------------------------------//
  static Future<MyResponse<Order>> getSingleOrder(int? id) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + id.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<Order> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Order.fromJson(json.decode(response.body!));
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }


  //------------------------ Get single order review -----------------------------------------//
  static Future<MyResponse<OrderReview>> getSingleOrderReview(int? id) async {

    log("1");
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.ORDERS +
        id.toString() +
        "/" +
        ApiUtil.REVIEWS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);
log("2");
    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }
log("3");
    try {
      NetworkResponse response = await Network.get(url, headers: headers);

     log("4");
      MyResponse<OrderReview> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        log("5");
        log(response.body.toString());
        myResponse.success = true;
        myResponse.data = OrderReview.fromJson(json.decode(response.body!));
        log("done");

        
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      log(e.toString());
      return MyResponse.makeServerProblemError<OrderReview>();
    }
  }

  //------------------------ Update payment status -----------------------------------------//
  static Future<MyResponse> updatePayment(
      int? orderId, bool success, String? paymentId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + orderId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['success'] = TextUtils.boolToString(success);
    data['payment_id'] = paymentId;

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(url, headers: headers, body: body);
      MyResponse myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError();
    }
  }

  //------------------------- update order for -----------------------------//
  static Future<MyResponse> updateOrder(int? orderId, int status) async {
    //Get Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.ORDERS + orderId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.PostWithAuth, token: token);

    //Body data
    Map data = ApiUtil.getPatchRequestBody();
    data['status'] = status;

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(
          url, headers: headers, body: body);

          log(response.body.toString());
      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    }catch(e){
      return MyResponse.makeServerProblemError();
    }
  }

}
