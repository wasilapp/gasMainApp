// ignore_for_file: public_member_api_docs, sort_constructors_first


import 'dart:developer';

import 'package:EMallApp/utils/navigator.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/widgets/FlutButton.dart';
import 'package:EMallApp/widgets/text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String fullNumber;
  const ResetPasswordScreen({
    Key? key,
    required this.fullNumber,
  }) : super(key: key);
  
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  //Theme Data
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Text-Field Controller
  TextEditingController? emailTFController;
  TextEditingController? passwordTFController;
    TextEditingController? confirmPasswordTFController;
  TextEditingController? _numberController;
  final GlobalKey _countryCodeSelectionKey = new GlobalKey();
  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  //Other Variables
  late bool isInProgress;
  bool showPassword = false;
    String contrycode ="962";

  //UI Variables
  OutlineInputBorder? allTFBorder;

  bool _rememberMe = false;

  void _onRememberMeChanged(bool newValue) {
    setState(() {
      _rememberMe = newValue;
    });
  }

  @override
  void initState() {
    super.initState();
  
    isInProgress = false;
    emailTFController = TextEditingController();
    passwordTFController = TextEditingController();
    confirmPasswordTFController = TextEditingController();

  }



  @override
  void dispose() {
    emailTFController!.dispose();
    passwordTFController!.dispose();
    super.dispose();
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
  }

  _handleLogin() async {
 
    String password = passwordTFController!.text;
    String confirmPassword = passwordTFController!.text;
    if (password.isEmpty || confirmPassword.isEmpty) {
      showMessage(message: Translator.translate("please_fill_password"));
      return;
    } else if (password!=confirmPassword) {
      showMessage(message: Translator.translate("password_are_not_same"));
      return;
    } else {
      if (mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      MyResponse response = await AuthController.forgotPassword(widget.fullNumber, password);
      log(response.data.toString());

      if(response.success==true){
        showMessage(message: Translator.translate("password_changed"));
 pushReplacementScreen(context, LoginScreen());
      }else{
         showMessage(message: response.errorText);
      }

       

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

       else {
       // ApiUtil.checkRedirectNavigation(context, response.responseCode);
        showMessage(message: response.errorText);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        _initUI();
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                key: _scaffoldKey,
                body: Container(
                    color: customAppTheme.bgLayer1,
                    child:  ListView(
                      padding: Spacing.top(150),
                      children: <Widget>[
                        Center(
               child: Image.asset(
                 'assets/images/logo.png',
                 width: 120.0,
                 height: 120.0,
               ),
             ),
                          Row(
               children: [
                 Padding(
    padding: const EdgeInsets.only(left: 20.0),
      child: Text(Translator.translate("password"),style: boldPrimary,),
  ),
               ],
             ),

               
        
              SizedBox(height: 20,),
             CustomTextField(
               keyBoard: TextInputType.text,
               controller: passwordTFController! ,
               isPassword:showPassword ,
               hintText: Translator.translate("password"),
               prefixIconData: Icons.lock,
               onPrefixIconPress: () {
                 setState(() {
                   showPassword = !showPassword;
                 });
               },
               
             ),

           
                SizedBox(height: 20,),
              CustomTextField(
               keyBoard: TextInputType.text,
               controller: confirmPasswordTFController! ,
               isPassword:showPassword ,
               hintText: Translator.translate("confirm_password"),
               prefixIconData: Icons.lock,
               onPrefixIconPress: () {
                 setState(() {
                   showPassword = !showPassword;
                 });
               },
               
             ),
                
                     
                    
                       
                        Container(
                          height: 50,
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: FlutButton.medium(
                            borderRadiusAll: 8,
                            onPressed: () {
                              if (!isInProgress) {
                               _handleLogin();
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    Translator.translate("confirm"),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        color: themeData
                                            .colorScheme.onPrimary,
                                        letterSpacing: 0.8,
                                        fontWeight: 700),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  child: isInProgress
                                      ? Container(
                                          width: MySize.size16,
                                          height: MySize.size16,
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                          Color>(
                                                      themeData
                                                          .colorScheme
                                                          .onPrimary),
                                              strokeWidth: 1.4),
                                        )
                                      : ClipOval(
                                          child: Container(
                                            // color: themeData.colorScheme
                                            //     .primaryVariant,

                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                       

                      ],
                    ))));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
