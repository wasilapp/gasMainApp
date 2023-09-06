import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:EMallApp/widgets/FlutButton.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'OTPVerificationScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Theme Data
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Text Field Editing Controller
  TextEditingController? _numberController;
  TextEditingController? nameTFController;
  TextEditingController? emailTFController;
  TextEditingController? passwordTFController;
  final GlobalKey _countryCodeSelectionKey = new GlobalKey();
  int selectedCountryCode = 0;
  List<PopupMenuEntry<Object>>? countryList;
  List<dynamic> countryCode = TextUtils.countryCode;
  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  new GlobalKey<ScaffoldMessengerState>();

  //Other Variables
  bool isInProgress = false;
  bool showPassword = false;
  String contrycode ="962";
  //UI Variables
  OutlineInputBorder? allTFBorder;

  @override
  void initState() {
    super.initState();
    nameTFController = TextEditingController();
    emailTFController = TextEditingController();
    passwordTFController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    nameTFController!.dispose();
    emailTFController!.dispose();
    passwordTFController!.dispose();
    _numberController!.dispose();
    super.dispose();
  }

  _handleRegister() async {
    String name = nameTFController!.text;
    String email = emailTFController!.text;
    String password = passwordTFController!.text;

    if (name.isEmpty) {
      showMessage(message: Translator.translate("please_fill_name"));
    }  else if (password.isEmpty) {
      showMessage(message: Translator.translate("please_fill_password"));
    } else {
      if (mounted) {
        setState(() {
          isInProgress = true;
        });
      }

      MyResponse response =
      await AuthController.registerUser(name, email,"${contrycode}${_numberController!.text}", password);

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

      if(response.errors.isNotEmpty){
        showMessage(message: response.errorText);
        return;
      }

      AuthType authType = await AuthController.userAuthType();

      if (authType == AuthType.VERIFIED) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => AppScreen()), (Route route) => false);
      } else if (authType == AuthType.LOGIN) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OTPVerificationScreen(),
          ),
        );
      } else {
     //   ApiUtil.checkRedirectNavigation(context, response.responseCode);
        showMessage(message: response.errorText.toString());
      }
    }
  }

  _initUI() {
    allTFBorder = OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(color: customAppTheme.bgLayer4, width: 1.5));
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
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                body: Container(
                    color: customAppTheme.bgLayer1,
                    child: ListView(
                      padding: Spacing.top(45),
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 54,
                            height: 54,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: Spacing.top(50),
                              padding: Spacing.all(15),
                              child: Text(
                                Translator.translate("create_account")
                                    .toUpperCase(),
                                style: boldPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 5, 24, 0),
                          child: TextFormField(
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                                hintText: Translator.translate("name"),
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: allTFBorder,
                                enabledBorder: allTFBorder,
                                focusedBorder: allTFBorder,
                                prefixIcon: Icon(
                                  MdiIcons.accountOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: Spacing.zero),
                            keyboardType: TextInputType.text,
                            controller: nameTFController,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 24, 24, 0),

                          // padding: Spacing.all(16),
                          child: Column(
                            children: <Widget>[
                              Row(
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
                                              'Select country: ${contrycode}');
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
                            ],
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: TextFormField(
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                                hintText: Translator.translate("email_address") + " " + Translator.translate("optional") ,
                                hintStyle: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    letterSpacing: 0.1,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500),
                                border: allTFBorder,
                                enabledBorder: allTFBorder,
                                focusedBorder: allTFBorder,
                                prefixIcon: Icon(
                                  MdiIcons.emailOutline,
                                  size: MySize.size22,
                                ),
                                isDense: true,
                                contentPadding: Spacing.zero),
                            keyboardType: TextInputType.emailAddress,
                            controller: emailTFController,
                          ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: TextFormField(
                            obscureText: showPassword,
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                letterSpacing: 0.1,
                                color: themeData.colorScheme.onBackground,
                                fontWeight: 500),
                            decoration: InputDecoration(
                              hintStyle: AppTheme.getTextStyle(
                                  themeData.textTheme.subtitle2,
                                  letterSpacing: 0.1,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 500),
                              hintText: Translator.translate("password"),
                              border: allTFBorder,
                              enabledBorder: allTFBorder,
                              focusedBorder: allTFBorder,
                              prefixIcon: Icon(
                                MdiIcons.lockOutline,
                                size: 22,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                child: Icon(
                                  showPassword
                                      ? MdiIcons.eyeOutline
                                      : MdiIcons.eyeOffOutline,
                                  size: MySize.size22,
                                ),
                              ),
                              isDense: true,
                              contentPadding: Spacing.zero,
                            ),
                            controller: passwordTFController,
                          ),
                        ),

                        Container(
                          margin: Spacing.fromLTRB(24, 16, 24, 0),
                          child: FlutButton.medium(
                            borderRadiusAll: 8,
                            onPressed: () async {
                              print(
                                  "${contrycode}${_numberController!.text}");
                              final prefs =
                              await SharedPreferences.getInstance();
                              await prefs.setString('number',
                                  "${contrycode}${_numberController!.text}");
                              if (!isInProgress) {
                                _handleRegister();
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    Translator.translate("create")
                                        .toUpperCase(),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        color: themeData.colorScheme.onPrimary,
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
                                        AlwaysStoppedAnimation<Color>(
                                            themeData.colorScheme
                                                .onPrimary),
                                        strokeWidth: 1.4),
                                  )
                                      : ClipOval(
                                    child: Container(
                                      // color: themeData
                                      //     .colorScheme.primaryVariant,
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
                                        builder: (context) => LoginScreen()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Translator.translate(
                                        "i_have_already_an_account"),
                                    style: AppTheme.getTextStyle(
                                        themeData.textTheme.bodyText2,
                                        color: themeData.colorScheme.onBackground,
                                        fontWeight: 500,
                                       ),
                                  ),
                                  SizedBox(width: 6,),
                                  Text(
                                    Translator.translate(
                                        "login"),
                                    style: basicPrimary,
                                  ),
                                ],
                              ),
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

  List<PopupMenuEntry<Object>> getCountryList() {
    if (countryList != null) return countryList!;
    countryList = <PopupMenuEntry<Object>>[];
    for (int i = 0; i < countryCode.length; i++) {
      countryList!.add(PopupMenuItem(
        value: i,
        child: Container(
          margin: Spacing.vertical(2),
          child: Text(
              countryCode[i]['name'] + " ( " + countryCode[i]['code'] + " )",
              style: AppTheme.getTextStyle(
                themeData.textTheme.subtitle2,
                color: themeData.colorScheme.onBackground,
              )),
        ),
      ));
      countryList!.add(
        PopupMenuDivider(
          height: 10,
        ),
      );
    }
    return countryList!;
  }

}
