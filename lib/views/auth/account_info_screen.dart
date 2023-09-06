import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Account.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/widgets/FlutButton.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfo extends StatefulWidget {
  const AccountInfo({Key? key}) : super(key: key);

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  //Text Field Editing Controller
  TextEditingController? _numberController;
  TextEditingController? nameTFController;
  TextEditingController? emailTFController;
 late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  new GlobalKey<ScaffoldMessengerState>();
  String contrycode ="+962";
  //Other Variables
  bool isInProgress = false;
  //User
  Account? account;
  //UI Variables
  OutlineInputBorder? allTFBorder;
  @override
  void initState() {
    super.initState();
    _initData();

    nameTFController = TextEditingController();
    emailTFController = TextEditingController();
    _numberController = TextEditingController();


  }

  

  @override
  void dispose() {
    nameTFController!.dispose();
    emailTFController!.dispose();

    _numberController = TextEditingController();
    super.dispose();
  }
  _initData() async {
    Account cacheAccount = await AuthController.getAccount();
    setState(() {
      account = cacheAccount;
      nameTFController!.text= account!.name.toString();
        emailTFController!.text= account!.mobile.toString();
        _numberController!.text= account!.email.toString();
    });
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
        builder: (BuildContext context, AppThemeNotifier value, Widget? child){
          int themeType = value.themeMode();
          themeData = AppTheme.getThemeFromThemeMode(themeType);
          customAppTheme = AppTheme.getCustomAppTheme(themeType);
          return Scaffold(
            appBar: AppBar(

              title: Center(child:Text(Translator.translate("account_info"),style: boldSecondry,)),
            ),
            body: Container(
                color: customAppTheme.bgLayer1,
                child: ListView(
                  padding: Spacing.top(45),
                  children: <Widget>[


                    Container(
                      margin: Spacing.fromLTRB(24, 5, 24, 0),
                      child: TextFormField(
                        style: AppTheme.getTextStyle(
                            themeData!.textTheme.bodyText1,
                            letterSpacing: 0.1,
                            color: themeData!.colorScheme.onBackground,
                            fontWeight: 500),
                        decoration: InputDecoration(
                            hintText: Translator.translate("name"),
                            hintStyle: AppTheme.getTextStyle(
                                themeData!.textTheme.subtitle2,
                                letterSpacing: 0.1,
                                color: themeData!.colorScheme.onBackground,
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
                                        fontSize: 15,
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
                            hintText: Translator.translate("email_address"),
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
                      child: FlutButton.medium(
                        borderRadiusAll: 8,
                        onPressed: () async {
                         
                          final prefs =
                          await SharedPreferences.getInstance();
                          await prefs.setString('mobile',
                              "${emailTFController!.text}");
                           await prefs.setString('email',
                              "${emailTFController!.text}");

                          await prefs.setString('name',
                              "${nameTFController!.text}");



                          if (!isInProgress) {

                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                Translator.translate("save")
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

                  ],
                )),
          );
        }



    );
  }
}
