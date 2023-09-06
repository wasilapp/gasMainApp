import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/models/Account.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/User.dart';
import 'package:EMallApp/services/Network.dart';
import 'package:EMallApp/services/PushNotificationsManager.dart';
import 'package:EMallApp/services/snakbar_service.dart';
import 'package:EMallApp/utils/InternetUtils.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppTheme.dart';

enum AuthType { VERIFIED, LOGIN, NOT_FOUND, BLOCKED }

class AuthController {
  //--------------------- Log In ---------------------------------------------//
  static Future<MyResponse> loginUser(String mobile, String password) async {
    //Get FCM

    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager.instance;

    pushNotificationsManager = PushNotificationsManager();
      pushNotificationsManager.init();

    //await pushNotificationsManager.init();
    String? fcmToken = await pushNotificationsManager.getToken();

    //URL
    String loginUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_LOGIN;

    //Body Data
    Map data = {'email': mobile , 'password': password, 'fcm_token': fcmToken};

    log(data.toString());

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(loginUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

      log(response.body.toString());
      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];
        String token = data['token'];

        await saveUser(user);

        await sharedPreferences.setString('token', token);

        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }

      return myResponse;
    } catch (e) {
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Check Mobile Availability ---------------------------------------------//
  static Future<MyResponse> mobileVerified(String? mobileNumber) async {
    //Get Token
    String? token = await AuthController.getApiToken();

    //URL
    String url = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_MOBILE_VERIFIED;

    //Body Data
    Map data = {'mobile': mobileNumber};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(
              requestType: RequestType.PostWithAuth, token: token),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];

        await saveUser(user);

        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Mobile Verified ---------------------------------------------//
  static Future<MyResponse> verifyMobileNumber(String mobileNumber) async {
    //Get Token
    String? token = await AuthController.getApiToken();

    //URL
    String url = ApiUtil.MAIN_API_URL + ApiUtil.MOBILE_NUMBER_VERIFY;

    //Body Data
    Map data = {'mobile': mobileNumber};

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(
              requestType: RequestType.PostWithAuth, token: token),
          body: body);

      MyResponse myResponse = MyResponse(response.statusCode);
      log(response.body!.toString());
      if (response.statusCode == 200) {

        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }
      return myResponse;
    } catch (e) {
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Register  ---------------------------------------------//
  static Future<MyResponse> registerUser(
      String name, String email,mobile, String password) async {
    //Add FCM Token
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.init();
    String? fcmToken = await pushNotificationsManager.getToken();

    //URL
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.AUTH_REGISTER;

    //Body
    Map data = {
      'name': name,
      'email': email,
      "mobile" : mobile,
      'password': password,
      'fcm_token': fcmToken
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if(!isConnected){
      return MyResponse.makeInternetConnectionError();
    }

    //Response
    try {
      NetworkResponse response = await Network.post(registerUrl,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);

          log(response.body.toString());

      MyResponse myResponse = MyResponse(response.statusCode);

      

      if (response.statusCode == 200) {
        log("i am is the success method");
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();

        Map<String, dynamic> data = json.decode(response.body!);
        Map<String, dynamic> user = data['user'];
        String token = data['token'];

        await sharedPreferences.setString('name', user['name']);
       // await sharedPreferences.setString('email', user['email']);
        // await sharedPreferences.setString(
        //     'avatar_url', user['avatar_url'] ?? "");
        await sharedPreferences.setString('token', token);
        await sharedPreferences.setBool('mobile_verified', false);

        myResponse.success = true;
      } else {
               log("i am is the not 200 method");
        Map<String, dynamic> data = json.decode(response.body!);
        log(data["errors"].toString());
         // showSnackBar(context, data["errors"]==null? data["message"].toString():data["errors"][0].toString() );
        myResponse.success = false;
      
        myResponse.setErrorForRegister(data);
        log("i am in the error method");
      }

      return myResponse;
    }catch(e){
      //If any server error...
      log("i am in the catch method");
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }
  }

  //--------------------- Forgot Password ---------------------------------------------//
  static Future<MyResponse> forgotPassword(String mobile,password) async {
    String url = ApiUtil.MAIN_API_URL + ApiUtil.FORGOT_PASSWORD;

    //Body date
    Map data = {
      'mobile': mobile,
      'password' : password
    };

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(url,
          headers: ApiUtil.getHeader(requestType: RequestType.Post),
          body: body);
        log(response.body.toString());
      MyResponse myResponse = MyResponse(response.statusCode);

      if (response.statusCode==200) {
        myResponse.success = true;
      } else {
        Map<String, dynamic> data = json.decode(response.body!);
        myResponse.success = false;
        myResponse.setError(data);
      }

      return myResponse;
    }catch(e){
      log(e.toString());
      return MyResponse.makeServerProblemError();
    }

  }


  //---------------------- Update user ------------------------------------------//
  static Future<MyResponse> updateUser(String password, File? imageFile) async {
    //Get Token
    String? token = await AuthController.getApiToken();
    String registerUrl = ApiUtil.MAIN_API_URL + ApiUtil.UPDATE_PROFILE;

    Map data = {};

    if (password.isNotEmpty) data['password'] = password;

    if (imageFile != null) {
      final bytes = imageFile.readAsBytesSync();
      String img64 =base64Encode(bytes);
      data['avatar_image'] = img64;
    }

    //Encode
    String body = json.encode(data);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError();
    }

    try {
      NetworkResponse response = await Network.post(registerUrl,
        headers: ApiUtil.getHeader(requestType: RequestType.PostWithAuth,token: token),
        body: body,);

      MyResponse myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body!);
        await saveUser(data['user']);
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


  //------------------------ Logout -----------------------------------------//
  static Future<bool> logoutUser() async {

    //Remove FCM Token
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.removeFCM();

    //Clear all Data
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await sharedPreferences.remove('name');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('avatar_url');
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('mobile');
    await sharedPreferences.remove('mobile_verified');
    await sharedPreferences.remove('blocked');

    return true;
  }

    static  Future deleteAccount(
      ) async {
         String? token = await AuthController.getApiToken();
            Map data = {
            "blocked" : 1
    };
     String body = json.encode(data);
    var res = await Network.post(ApiUtil.MAIN_API_URL + "delete", headers: ApiUtil.getHeader(requestType: RequestType.PostWithAuth,token: token!),body:body);
    log(ApiUtil.MAIN_API_URL + "delete");
    log("Deleting : ");
    log(res.body.toString());

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    await sharedPreferences.remove('id');
    await sharedPreferences.remove('name');
    await sharedPreferences.remove('email');
    await sharedPreferences.remove('avatar_url');
    await sharedPreferences.remove('token');
    await sharedPreferences.remove('mobile');
    await sharedPreferences.remove('mobile_verified');
    await sharedPreferences.remove('blocked');

    return true;
  }

  //------------------------ Save user in cache -----------------------------------------//
  static saveUser(Map<String,dynamic> user) async {
    await saveUserFromUser(User.fromJson(user));
  }

  static saveUserFromUser(User user) async {
   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('id', user.id);
    await sharedPreferences.setString('name', user.name!);
    await sharedPreferences.setString('email', user.email!);
    await sharedPreferences.setBool('mobile_verified', user.mobileVerified);
    await sharedPreferences.setString('avatar_url', user.avatarUrl!);
    await sharedPreferences.setString('mobile', user.mobile!);
    await sharedPreferences.setBool('blocked', user.blocked);
  }


  //------------------------ Get user from cache -----------------------------------------//
  static Future<Account> getAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? id = sharedPreferences.getInt('id');
    String? name = sharedPreferences.getString('name');
    String? email = sharedPreferences.getString('email');
    String? mobile = sharedPreferences.getString('mobile');
    String? token = sharedPreferences.getString('token');
    String? avatarUrl = sharedPreferences.getString('avatar_url');

    return Account(id,name,mobile, email, token, avatarUrl);
  }

  //------------------------ Check user logged in or not -----------------------------------------//
  static Future<AuthType> userAuthType() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String? token = sharedPreferences.getString("token");
      bool mobileVerified =
          sharedPreferences.getBool('mobile_verified') ?? false;
      bool blocked = sharedPreferences.getBool('blocked') ?? false;
      if (blocked) {
        return AuthType.BLOCKED;
      }
      if (token == null) {
        return AuthType.NOT_FOUND;
      } else if (!mobileVerified) {
        return AuthType.LOGIN;
      }
      return AuthType.VERIFIED;
    } catch (e) {}
    return AuthType.NOT_FOUND;
  }

  //------------------------ Get api token -----------------------------------------//
  static Future<String?> getApiToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("token");
  }

  //------------------------ Testing notice -------------------------------------//

  static Widget notice(ThemeData themeData){
    return Container(
      margin: Spacing.fromLTRB(24, 36, 24, 24),
      child: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                  text: "Note: ",
                  style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,color: themeData.colorScheme.primary,fontWeight: 600)
              ),
              TextSpan(
                  text: "After testing please logout, because there is many user testing with same IDs so it can be possible that you can get unnecessary notifications",
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,color: themeData.colorScheme.onBackground,fontWeight: 500,letterSpacing: 0)
              ),
            ]
        ),
      ),
    );
  }


}
