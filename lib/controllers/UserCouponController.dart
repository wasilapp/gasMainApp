import 'dart:convert';
import 'dart:developer';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Coupon.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/UserWallet.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/utils/InternetUtils.dart';

import 'AuthController.dart';

class UserCouponController {

  static double total_wallet = 0;

  //------------------------ Get all coupons -----------------------------------------//
  static Future<MyResponse<List<Coupon>>> getCouponForShop(int? shopId) async {
    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.SHOP_COUPON + shopId.toString();
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Coupon>>();
    }

    try {
      NetworkResponse response = await Network.get(
        url,
        headers: headers,
      );
      log(response.body.toString());
      MyResponse<List<Coupon>> myResponse = MyResponse(response.statusCode);
      if (ApiUtil.isResponseSuccess(response.statusCode!)) {
        myResponse.success = true;
        myResponse.data = Coupon.getListFromJson(json.decode(response.body!));
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      //If any server error...

      return MyResponse.makeServerProblemError<List<Coupon>>();
    }
  }


  static Future<MyResponse<UserWallet>> getWallet() async {

    //Getting User Api Token
    String? token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.UserWallet ;
    Map<String, String> headers =
    ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<UserWallet>();
    }

    try {
      NetworkResponse response = await Network.get(url, headers: headers);
      MyResponse<UserWallet> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        log("wallet:  " + response.body.toString());
        print("sub done");
        myResponse.success = true;
        myResponse.data = UserWallet.fromJson(json.decode(response.body!));

        

      } else {
        myResponse.setError(json.decode(response.body!));
      }

      return myResponse;
    } catch (e) {
      print("sub error");
      //If any server error...
      return MyResponse.makeServerProblemError<UserWallet>();
    }
  }

}
