

import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/Validator.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/utils/navigator.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/BlockedScreen.dart';
import 'package:EMallApp/views/auth/ForgotPasswordScreen.dart';
import 'package:EMallApp/views/auth/OTPVerificationScreen.dart';
import 'package:EMallApp/views/auth/RegisterScreen.dart';
import 'package:EMallApp/widgets/FlutButton.dart';
import 'package:EMallApp/widgets/text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Theme Data
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Text-Field Controller
  TextEditingController? emailTFController;
  TextEditingController? passwordTFController;
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
    _checkUserLoginOrNot();
    isInProgress = false;
    emailTFController = TextEditingController();
    passwordTFController = TextEditingController();
    _numberController = TextEditingController();
  }

  _checkUserLoginOrNot() async {
    AuthType authType = await AuthController.userAuthType();
    if (authType == AuthType.VERIFIED) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AppScreen(),
        ),
        (route) => false,
      );
    } else if (authType == AuthType.LOGIN) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OTPVerificationScreen(),
        ),
        (route) => false,
      );
    }
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
    String mobile = _numberController!.text;
    String password = passwordTFController!.text;

    if (mobile.isEmpty) {
      showMessage(message: Translator.translate("please_fill_mobile"));
    } else if (password.isEmpty) {
      showMessage(message: Translator.translate("please_fill_password"));
    } else {
      if (mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      MyResponse response = await AuthController.loginUser("+" + contrycode +mobile, password);
      log(response.data.toString());
      AuthType authType = await AuthController.userAuthType();

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

      if (authType == AuthType.VERIFIED) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AppScreen(),
          ),
        );
      } else if (authType == AuthType.LOGIN) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OTPVerificationScreen(),
          ),
        );
      } else if (authType == AuthType.BLOCKED) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => BlockedScreen(),
          ),
        );
      } else {
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
      child: Text(Translator.translate("Sign in"),style: boldPrimary,),
  ),
               ],
             ),

               SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(right:20,left: 20),
                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showCountryPicker(
                                          context: context,
                                          //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
                                          exclude: <String>['KN', 'MF'],
                                          favorite: <String>['SE'],
                                          //Optional. Shows phone code before the country name.
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            setState(() {
                                              contrycode = country.phoneCode;
                                            });
                                            print(
                                                'Select country: ${country.displayName}');
                                          },
                                          // Optional. Sets the theme for the country list picker.
                                          countryListTheme: CountryListThemeData(
                                            // Optional. Sets the border radius for the bottomsheet.
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40.0),
                                              topRight: Radius.circular(40.0),
                                            ),
                                            // Optional. Styles the search field.
                                            inputDecoration: InputDecoration(
                                              labelText: 'Search',
                                              hintText: 'Start typing to search',
                                              prefixIcon:
                                              const Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: const Color(0xFF8C98A8)
                                                      .withOpacity(0.2),
                                                ),
                                              ),
                                            ),
                                            // Optional. Styles the text in the search field
                                            searchTextStyle: TextStyle(
                                              color: Colors.green,
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      },
                                      child:  Text(contrycode),
                                    ),
                                    Spacing.width(8),
                                    Expanded(
                                      child: TextFormField(
                                        style: AppTheme.getTextStyle(
                                            themeData.textTheme.bodyText1,
                                            letterSpacing: 0.1,
                                            color: themeData
                                                .colorScheme.onBackground,
                                            fontWeight: 500),
                                        decoration: InputDecoration(
                                            hintText: Translator.translate(
                                                "mobile_number"),
                                            hintStyle: AppTheme.getTextStyle(
                                                themeData.textTheme.subtitle2,
                                                letterSpacing: 0.1,
                                                color: themeData
                                                    .colorScheme.onBackground,
                                                fontWeight: 500),
                                            border: allTFBorder,
                                            enabledBorder: allTFBorder,
                                            focusedBorder: allTFBorder,
                                            prefixIcon: Icon(
                                              MdiIcons.phone,
                                              size: MySize.size22,
                                            ),
                                            isDense: true,
                                            contentPadding: Spacing.zero),
                                        keyboardType: TextInputType.number,
                                        autofocus: false,
                                        textCapitalization:
                                        TextCapitalization.sentences,
                                        controller: _numberController,
                                      ),
                                    ),
                                  ],
                                ),
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
                     
                    
                        Container(
                          margin: Spacing.fromLTRB(24,8,24,0),
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen()));
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             ForgotPasswordScreen()));
                            },
                            child: Text(
                              Translator.translate("forgot_password")+" ?",
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  fontWeight: 500),
                            ),
                          ),
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
                                    Translator.translate("Sign in"),
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
                        Center(
                          child: Container(
                            margin: Spacing.top(16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Translator.translate("i_have_not_an_account"),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: 500,
                                        ),
                                  ),
                                  SizedBox(width: 6,),
                                  Text(Translator.translate("register"),style: basicPrimary,)
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15,),
                         InkWell(
                          onTap: () {
                            pushScreen(context, AppScreen());
                          },
                           child: Center(
                             child: Text(
                                  Translator.translate("visitor"),
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: Colors.greenAccent,
                                      fontSize: 24,
                                      fontWeight: 500),
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
